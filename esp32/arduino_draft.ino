#include <ArduinoJson.h>
#include <DHTesp.h>
#include <HTTPClient.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#if defined(DEBUG) || defined(CORE_DEBUG_LEVEL) || !defined(NDEBUG)
#define INSECURE_TLS_DEBUG_BUILD 1
#endif

#include "secrets.h"

constexpr int DHT_PIN = 15;
constexpr bool DEMO_MODE = false;
constexpr unsigned long STANDARD_INTERVAL_MS = 5UL * 60UL * 1000UL;
constexpr unsigned long DEMO_INTERVAL_MS = 10UL * 1000UL;
constexpr unsigned long HTTP_TIMEOUT_MS = 15000;
constexpr int WIFI_MAX_RETRIES = 40;
constexpr unsigned long MIN_DHT_INTERVAL_MS = 1000;
constexpr unsigned long RETRY_INTERVAL_MS = 30000;
constexpr size_t MAX_SECRET_LEN = 255;
constexpr size_t MAX_URL_LEN = 256;
constexpr size_t MAX_HEADER_LEN = 256;
constexpr size_t JSON_DOC_CAPACITY = 200;

DHTesp dht;
WiFiClientSecure secureClient;
unsigned long lastSendMs = 0;
unsigned long lastDhtMs = 0;
unsigned long nextDueMs = 0;
bool tlsConfigured = false;
bool secretsReady = false;

size_t boundedStrlen(const char *value, size_t maxLen) {
    if (value == nullptr) {
        return 0;
    }
#if defined(ARDUINO_ARCH_ESP32)
    return strnlen(value, maxLen);
#else
    size_t len = 0;
    while (len < maxLen && value[len] != '\0') {
        len++;
    }
    return len;
#endif
}

bool safeFormat(char *buffer, size_t bufferSize, const char *format, ...) {
    if (buffer == nullptr || format == nullptr || bufferSize == 0) {
        return false;
    }
    va_list args;
    va_start(args, format);
    int written = vsnprintf(buffer, bufferSize, format, args);
    va_end(args);
    return written >= 0 && written < static_cast<int>(bufferSize);
}

bool intervalElapsed(unsigned long last, unsigned long interval, unsigned long now) {
    return last == 0 || static_cast<uint32_t>(now - last) >= interval;
}

bool validateSecrets() {
    if (DEVICE_ID == nullptr || SUPABASE_ANON_KEY == nullptr || SUPABASE_URL == nullptr) {
        return false;
    }
    size_t deviceLen = boundedStrlen(DEVICE_ID, MAX_SECRET_LEN);
    size_t keyLen = boundedStrlen(SUPABASE_ANON_KEY, MAX_SECRET_LEN);
    size_t urlLen = boundedStrlen(SUPABASE_URL, MAX_SECRET_LEN);
    return deviceLen > 0 && strncmp(DEVICE_ID, "YOUR_", 5) != 0 &&
           keyLen > 0 && strncmp(SUPABASE_ANON_KEY, "YOUR_", 5) != 0 &&
           urlLen > 0 && strstr(SUPABASE_URL, "<PROJECT_REF>") == nullptr;
}

void configureTls() {
    secureClient.setTimeout(HTTP_TIMEOUT_MS);
    tlsConfigured = false;
    if (SUPABASE_ROOT_CA[0] != '\0') {
        secureClient.setCACert(SUPABASE_ROOT_CA);
        Serial.println("TLS: using provided root CA.");
        tlsConfigured = true;
    }
#if defined(INSECURE_TLS_DEBUG_BUILD)
    else if (ALLOW_INSECURE_TLS) {
        secureClient.setInsecure();
        Serial.println("TLS: WARNING using insecure mode (no certificate validation).");
        tlsConfigured = true;
    }
#else
    else if (ALLOW_INSECURE_TLS) {
        Serial.println("TLS: ALLOW_INSECURE_TLS is ignored unless built with DEBUG.");
    }
#endif
    else {
        Serial.println("TLS: no root CA configured; set SUPABASE_ROOT_CA or enable ALLOW_INSECURE_TLS for testing.");
    }
}

void connectWiFi() {
    if (WiFi.status() == WL_CONNECTED) {
        return;
    }

    WiFi.mode(WIFI_STA);
    WiFi.setAutoReconnect(true);
    WiFi.persistent(false);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    Serial.println("Connecting to Wi-Fi...");
    int retries = 0;
    while (WiFi.status() != WL_CONNECTED && retries < WIFI_MAX_RETRIES) {
        delay(250);
        Serial.print(".");
        retries++;
    }
    Serial.println();

    if (WiFi.status() == WL_CONNECTED) {
        Serial.print("Wi-Fi connected, IP: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.printf("Wi-Fi connection failed after %d attempts (~%lus); will retry.\n", WIFI_MAX_RETRIES, (WIFI_MAX_RETRIES * 250UL) / 1000UL);
    }
}

void ensureWiFiConnected() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Wi-Fi disconnected; attempting reconnection.");
        connectWiFi();
    }
}

bool readSensor(float &temperature, float &humidity) {
    unsigned long now = millis();
    if (!intervalElapsed(lastDhtMs, MIN_DHT_INTERVAL_MS, now)) {
        Serial.println("DHT11 read skipped: sampling too quickly.");
        return false;
    }
    TempAndHumidity data = dht.getTempAndHumidity();
    if (isnan(data.temperature) || isnan(data.humidity)) {
        Serial.println("DHT11 reading is NaN; skipping upload.");
        return false;
    }

    temperature = data.temperature;
    humidity = data.humidity;
    lastDhtMs = now;
    Serial.printf("DHT11 -> temp: %.2f°C, humidity: %.2f%%\n", temperature, humidity);
    return true;
}

bool postReading(float temperature, float humidity) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Cannot POST: Wi-Fi not connected.");
        return false;
    }
    if (!tlsConfigured) {
        Serial.println("Cannot POST: TLS is not configured. Add SUPABASE_ROOT_CA or enable ALLOW_INSECURE_TLS.");
        return false;
    }
    if (!secretsReady) {
        Serial.println("Cannot POST: secrets placeholders detected; update secrets.h.");
        return false;
    }

    char url[MAX_URL_LEN];
    if (!safeFormat(url, sizeof(url), "%s/rest/v1/readings", SUPABASE_URL)) {
        Serial.println("Cannot POST: SUPABASE_URL is too long.");
        return false;
    }
    HTTPClient http;
    http.begin(secureClient, url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Prefer", "return=minimal");
    http.addHeader("apikey", SUPABASE_ANON_KEY);
    char authHeader[MAX_HEADER_LEN];
    if (!safeFormat(authHeader, sizeof(authHeader), "Bearer %s", SUPABASE_ANON_KEY)) {
        Serial.println("Cannot POST: SUPABASE_ANON_KEY is too long for Authorization header.");
        return false;
    }
    http.addHeader("Authorization", authHeader);

    StaticJsonDocument<JSON_DOC_CAPACITY> payload;
    payload["device_id"] = DEVICE_ID;
    payload["temperature"] = temperature;
    payload["humidity"] = humidity;

    String body;
    serializeJson(payload, body);

    Serial.printf("POST %s\n", url);
    int httpStatus = http.POST(body);
    if (httpStatus > 0) {
        Serial.printf("HTTP status: %d\n", httpStatus);
    } else {
        Serial.printf("HTTP POST failed: %s\n", http.errorToString(httpStatus).c_str());
        Serial.println("Will retry sooner after a transient failure.");
    }
    http.end();
    return httpStatus >= 200 && httpStatus < 300;
}

void setup() {
    Serial.begin(115200);
    delay(200);
    Serial.println("ESP32 Stage 1: DHT11 to Supabase REST");

    dht.setup(DHT_PIN, DHTesp::DHT11);
    Serial.printf("DHT11 initialized on GPIO %d\n", DHT_PIN);

    secretsReady = validateSecrets();
    if (!secretsReady) {
        Serial.println("secrets.h placeholders detected (DEVICE_ID, SUPABASE_URL, or SUPABASE_ANON_KEY); update before running.");
#ifdef LED_BUILTIN
        pinMode(LED_BUILTIN, OUTPUT);
#endif
        while (true) {
            Serial.println("CRITICAL: update secrets.h (DEVICE_ID/SUPABASE_URL/SUPABASE_ANON_KEY). Halting.");
#ifdef LED_BUILTIN
            digitalWrite(LED_BUILTIN, HIGH);
            delay(150);
            digitalWrite(LED_BUILTIN, LOW);
            delay(150);
#else
            delay(300);
#endif
        }
    }

    configureTls();
    connectWiFi();

    lastSendMs = 0;
}

void loop() {
    ensureWiFiConnected();

    unsigned long interval = DEMO_MODE ? DEMO_INTERVAL_MS : STANDARD_INTERVAL_MS;
    unsigned long now = millis();
    bool retryDue = nextDueMs != 0 && static_cast<uint32_t>(now - nextDueMs) < 0x80000000;

    if (retryDue || intervalElapsed(lastSendMs, interval, now)) {
        lastSendMs = now;
        nextDueMs = 0;
        float temperature;
        float humidity;

        if (readSensor(temperature, humidity)) {
            if (!postReading(temperature, humidity)) {
                nextDueMs = now + RETRY_INTERVAL_MS;
            }
        }
    }

    delay(100);
}

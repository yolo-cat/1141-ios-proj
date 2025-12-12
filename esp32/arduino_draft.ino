#include <ArduinoJson.h>
#include <DHTesp.h>
#include <HTTPClient.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>

#include "secrets.h"

const int DHT_PIN = 15;
const bool DEMO_MODE = false;
const unsigned long STANDARD_INTERVAL_MS = 5UL * 60UL * 1000UL;
const unsigned long DEMO_INTERVAL_MS = 10UL * 1000UL;

DHTesp dht;
WiFiClientSecure secureClient;
unsigned long lastSendMs = 0;

void configureTls() {
    secureClient.setTimeout(15000);
    if (strlen(SUPABASE_ROOT_CA) > 0) {
        secureClient.setCACert(SUPABASE_ROOT_CA);
        Serial.println("TLS: using provided root CA.");
    } else if (ALLOW_INSECURE_TLS) {
        secureClient.setInsecure();
        Serial.println("TLS: WARNING using insecure mode (no certificate validation).");
    } else {
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

    Serial.printf("Connecting to Wi-Fi SSID: %s\n", WIFI_SSID);
    int retries = 0;
    while (WiFi.status() != WL_CONNECTED && retries < 40) {
        delay(250);
        Serial.print(".");
        retries++;
    }
    Serial.println();

    if (WiFi.status() == WL_CONNECTED) {
        Serial.print("Wi-Fi connected, IP: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.println("Wi-Fi connection failed; will retry.");
    }
}

void ensureWiFiConnected() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Wi-Fi disconnected; attempting reconnection.");
        connectWiFi();
    }
}

bool readSensor(float &temperature, float &humidity) {
    TempAndHumidity data = dht.getTempAndHumidity();
    if (isnan(data.temperature) || isnan(data.humidity)) {
        Serial.println("DHT11 reading is NaN; skipping upload.");
        return false;
    }

    temperature = data.temperature;
    humidity = data.humidity;
    Serial.printf("DHT11 -> temp: %.2f°C, humidity: %.2f%%\n", temperature, humidity);
    return true;
}

bool postReading(float temperature, float humidity) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Cannot POST: Wi-Fi not connected.");
        return false;
    }

    String url = String(SUPABASE_URL) + "/rest/v1/readings";
    HTTPClient http;
    http.begin(secureClient, url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Prefer", "return=minimal");
    http.addHeader("apikey", SUPABASE_ANON_KEY);
    http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);

    StaticJsonDocument<200> payload;
    payload["device_id"] = DEVICE_ID;
    payload["temperature"] = temperature;
    payload["humidity"] = humidity;

    String body;
    serializeJson(payload, body);

    Serial.printf("POST %s\n", url.c_str());
    int httpStatus = http.POST(body);
    if (httpStatus > 0) {
        Serial.printf("HTTP status: %d\n", httpStatus);
    } else {
        Serial.printf("HTTP POST failed: %s\n", http.errorToString(httpStatus).c_str());
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

    configureTls();
    connectWiFi();

    unsigned long firstInterval = DEMO_MODE ? DEMO_INTERVAL_MS : STANDARD_INTERVAL_MS;
    lastSendMs = millis() - firstInterval;
}

void loop() {
    ensureWiFiConnected();

    unsigned long interval = DEMO_MODE ? DEMO_INTERVAL_MS : STANDARD_INTERVAL_MS;
    unsigned long now = millis();

    if (now - lastSendMs >= interval) {
        lastSendMs = now;
        float temperature;
        float humidity;

        if (readSensor(temperature, humidity)) {
            postReading(temperature, humidity);
        }
    }

    delay(100);
}

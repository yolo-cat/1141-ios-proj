/*
 * File: esp32/arduino_stage2/arduino_stage2.ino
 * Purpose: ESP32 firmware for reading DHT11 sensors and uploading via HTTPS.
 * Architecture: Arduino/C++. Dependencies: ArduinoJson, DHTesp, HTTPClient.
 * AI Context: Edge device logic. Supports DEMO_MODE for high-frequency testing.
 */

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

// 定義常數
constexpr int DHT_PIN = 32;       // DHT11 感測器連接的 GPIO 腳位
constexpr bool DEMO_MODE = false; // 是否啟用示範模式（縮短間隔）
constexpr unsigned long STANDARD_INTERVAL_MS =
    5UL * 60UL * 1000UL; // 標準上傳間隔（5 分鐘）
constexpr unsigned long DEMO_INTERVAL_MS =
    10UL * 1000UL;                               // 示範模式上傳間隔（10 秒）
constexpr unsigned long HTTP_TIMEOUT_MS = 15000; // HTTP 請求超時時間（毫秒）
constexpr unsigned long MIN_DHT_INTERVAL_MS =
    1000; // DHT11 讀取最小間隔（避免過快取樣）
constexpr unsigned long RETRY_INTERVAL_MS = 30000; // 上傳失敗後重試間隔（毫秒）
constexpr size_t MAX_SECRET_LEN = 255;             // 秘密字串最大長度
constexpr size_t MAX_URL_LEN = 256;                // URL 字串最大長度
constexpr size_t MAX_HEADER_LEN = 256;             // HTTP 標頭最大長度
constexpr size_t JSON_DOC_CAPACITY = 200;          // JSON 文件容量

// 全域變數
DHTesp dht;                    // DHT11 感測器物件
WiFiClientSecure secureClient; // 安全 Wi-Fi 客戶端
unsigned long lastSendMs = 0;  // 上次上傳時間戳記
unsigned long lastDhtMs = 0;   // 上次 DHT11 讀取時間戳記
unsigned long nextDueMs = 0;   // 下次重試時間戳記
bool tlsConfigured = false;    // TLS 是否已配置
bool secretsReady = false;     // 秘密是否準備就緒

// 計算字串長度，限制最大長度
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

// 安全格式化字串，避免緩衝區溢位
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

// 檢查時間間隔是否已過
bool intervalElapsed(unsigned long last, unsigned long interval,
                     unsigned long now) {
  return last == 0 || static_cast<uint32_t>(now - last) >= interval;
}

// 驗證秘密字串是否有效（非預設值）
bool validateSecrets() {
  if (DEVICE_ID == nullptr || SUPABASE_ANON_KEY == nullptr ||
      SUPABASE_URL == nullptr) {
    return false;
  }
  size_t deviceLen = boundedStrlen(DEVICE_ID, MAX_SECRET_LEN);
  size_t keyLen = boundedStrlen(SUPABASE_ANON_KEY, MAX_SECRET_LEN);
  size_t urlLen = boundedStrlen(SUPABASE_URL, MAX_SECRET_LEN);
  return deviceLen > 0 && strncmp(DEVICE_ID, "YOUR_", 5) != 0 && keyLen > 0 &&
         strncmp(SUPABASE_ANON_KEY, "YOUR_", 5) != 0 && urlLen > 0 &&
         strstr(SUPABASE_URL, "<PROJECT_REF>") == nullptr;
}

// 配置 TLS 安全連線
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
    Serial.println(
        "TLS: WARNING using insecure mode (no certificate validation).");
    tlsConfigured = true;
  }
#else
  else if (ALLOW_INSECURE_TLS) {
    Serial.println(
        "TLS: ALLOW_INSECURE_TLS is ignored unless built with DEBUG.");
  }
#endif
  else {
    Serial.println("TLS: no root CA configured; set SUPABASE_ROOT_CA or enable "
                   "ALLOW_INSECURE_TLS for testing.");
  }
}

// 外部宣告 (來自 wifi_config.ino)
extern void setupWiFi();
extern void loopWiFi();
extern void checkWiFiConnection();

// 讀取 DHT11 感測器資料
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
  Serial.printf("DHT11 -> temp: %.2f°C, humidity: %.2f%%\n", temperature,
                humidity);
  return true;
}

// 將讀取資料 POST 至 Supabase
bool postReading(float temperature, float humidity) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Cannot POST: Wi-Fi not connected.");
    return false;
  }
  if (!tlsConfigured) {
    Serial.println("Cannot POST: TLS is not configured. Add SUPABASE_ROOT_CA "
                   "or enable ALLOW_INSECURE_TLS.");
    return false;
  }
  if (!secretsReady) {
    Serial.println(
        "Cannot POST: secrets placeholders detected; update secrets.h.");
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
  if (!safeFormat(authHeader, sizeof(authHeader), "Bearer %s",
                  SUPABASE_ANON_KEY)) {
    Serial.println(
        "Cannot POST: SUPABASE_ANON_KEY is too long for Authorization header.");
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
    Serial.printf("HTTP POST failed: %s\n",
                  http.errorToString(httpStatus).c_str());
    Serial.println("Will retry sooner after a transient failure.");
  }
  http.end();
  return httpStatus >= 200 && httpStatus < 300;
}

// 初始化設定
void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println("ESP32 Stage 1: DHT11 to Supabase REST");

  dht.setup(DHT_PIN, DHTesp::DHT11);
  Serial.printf("DHT11 initialized on GPIO %d\n", DHT_PIN);

  secretsReady = validateSecrets();
  if (!secretsReady) {
    Serial.println("secrets.h placeholders detected (DEVICE_ID, SUPABASE_URL, "
                   "or SUPABASE_ANON_KEY); update before running.");
#ifdef LED_BUILTIN
    pinMode(LED_BUILTIN, OUTPUT);
#endif
    while (true) {
      Serial.println("CRITICAL: update secrets.h "
                     "(DEVICE_ID/SUPABASE_URL/SUPABASE_ANON_KEY). Halting.");
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
  setupWiFi();

  lastSendMs = 0;
}

// 主迴圈
void loop() {
  loopWiFi();
  checkWiFiConnection();

  unsigned long interval = DEMO_MODE ? DEMO_INTERVAL_MS : STANDARD_INTERVAL_MS;
  unsigned long now = millis();
  bool retryDue =
      nextDueMs != 0 && static_cast<uint32_t>(now - nextDueMs) < 0x80000000;

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
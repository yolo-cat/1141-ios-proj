#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHTesp.h>
#include "secrets.h"

// Stage-1 firmware: read DHT11 (GPIO 15) and POST to Supabase REST.

const int DHT_PIN = 15;
const bool DEMO_MODE = true; // Demo: 10s；Standard: 5 minutes
const unsigned long STANDARD_UPLOAD_INTERVAL_MS = 5UL * 60UL * 1000UL;
const unsigned long DEMO_UPLOAD_INTERVAL_MS = 10UL * 1000UL;
const bool RUN_PAYLOAD_SELF_TEST = false; // enable for dev-only payload shape check
const bool ALLOW_INSECURE_TLS = false;  // set true only for local debugging

DHTesp dht;
unsigned long lastReadingAt = 0;
String supabaseEndpoint;

void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  Serial.print("Connecting WiFi");
  WiFi.begin(FPSTR(WIFI_SSID), FPSTR(WIFI_PASSWORD));
  uint8_t attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\nWiFi connected, IP: %s\n", WiFi.localIP().toString().c_str());
  } else {
    Serial.println("\nWiFi connection failed");
  }
}

String buildPayload(float temperature, float humidity) {
  StaticJsonDocument<200> doc;
  doc["device_id"] = FPSTR(DEVICE_ID);
  doc["temperature"] = temperature;
  doc["humidity"] = humidity;

  String json;
  serializeJson(doc, json);
  return json;
}

void runPayloadSelfTest() {
  String payload = buildPayload(25.1, 61.2);
  bool hasDevice = payload.indexOf("device_id") >= 0;
  bool hasTemp = payload.indexOf("temperature") >= 0;
  bool hasHumidity = payload.indexOf("humidity") >= 0;
  Serial.println(hasDevice && hasTemp && hasHumidity
                     ? "[self-test] payload fields OK"
                     : "[self-test] payload fields missing");
}

bool isValidReading(const TempAndHumidity &data) {
  return !isnan(data.temperature) && !isnan(data.humidity);
}

bool readSensor(float &temperature, float &humidity) {
  TempAndHumidity data = dht.getTempAndHumidity();
  if (!isValidReading(data)) {
    Serial.println("NaN reading detected, skip upload");
    return false;
  }

  temperature = data.temperature;
  humidity = data.humidity;
  return true;
}

bool postReading(float temperature, float humidity) {
  WiFiClientSecure client;
  size_t caLen = strlen_P(SUPABASE_ROOT_CA);
  bool hasRootCA = caLen > 0;
  if (hasRootCA) {
    client.setCACert_P(SUPABASE_ROOT_CA);
  } else if (ALLOW_INSECURE_TLS) {
    client.setInsecure(); // dev-only fallback
  } else {
    Serial.println("Skip upload: missing Supabase root CA (set ALLOW_INSECURE_TLS=true for dev)");
    return false;
  }

  HTTPClient http;
  if (!http.begin(client, supabaseEndpoint)) {
    Serial.println("HTTP begin failed");
    return false;
  }

  http.addHeader("Content-Type", "application/json");
  http.addHeader("Prefer", "return=minimal");
  http.addHeader("apikey", String(FPSTR(SUPABASE_ANON_KEY)));
  http.addHeader("Authorization", String("Bearer ") + FPSTR(SUPABASE_ANON_KEY));

  String payload = buildPayload(temperature, humidity);
  int code = http.POST(payload);

  if (code > 0) {
    Serial.printf("POST %d\n", code);
  } else {
    Serial.printf("POST error: %s\n", http.errorToString(code).c_str());
  }

  http.end();
  return code >= 200 && code < 300;
}

void setup() {
  Serial.begin(115200);
  dht.setup(DHT_PIN, DHTesp::DHT11);
  Serial.printf("DHT11 initialized on GPIO %d\n", DHT_PIN);

  supabaseEndpoint = String(FPSTR(SUPABASE_URL)) + "/rest/v1/readings";

  if (RUN_PAYLOAD_SELF_TEST) {
    runPayloadSelfTest();
  }

  connectWiFi();
}

void loop() {
  unsigned long now = millis();
  unsigned long interval = DEMO_MODE ? DEMO_UPLOAD_INTERVAL_MS : STANDARD_UPLOAD_INTERVAL_MS;

  if (now - lastReadingAt < interval) {
    return;
  }
  lastReadingAt = now;

  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("Skip upload: WiFi unavailable");
      return;
    }
  }

  float temperature = 0.0f;
  float humidity = 0.0f;
  if (!readSensor(temperature, humidity)) {
    return;
  }

  Serial.printf("Sending device=%s temp=%.2f humidity=%.2f\n", FPSTR(DEVICE_ID), temperature, humidity);
  postReading(temperature, humidity);
}

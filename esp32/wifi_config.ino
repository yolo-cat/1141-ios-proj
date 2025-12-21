#include <WiFiManager.h>

// WiFi 相關常數
const char *WIFI_AP_NAME = "ESP32-Setup";
constexpr int WIFI_PORTAL_TIMEOUT_S = 180;    // 3 分鐘內未設定則超時
constexpr int RESET_BTN_PIN = 4;              // 重置按鈕 GPIO
constexpr unsigned long RESET_HOLD_MS = 3000; // 長按 3 秒

void setupWiFi() {
  WiFi.mode(WIFI_STA); // 明確設定為 Station 模式

  // 初始化重置按鈕
  if (RESET_BTN_PIN >= 0) {
    pinMode(RESET_BTN_PIN, INPUT_PULLUP);
  }

  WiFiManager wm;

  // 設定
  wm.setConfigPortalTimeout(WIFI_PORTAL_TIMEOUT_S);
  wm.setConnectTimeout(30); // 連線超時

  Serial.println("WiFiManager: Attempting autoConnect...");

  // 啟動 AutoConnect
  // 如果之前有存過 WiFi 會自動連線，否則開啟名為 WIFI_AP_NAME 的熱點
  if (!wm.autoConnect(WIFI_AP_NAME)) {
    Serial.println("WiFiManager: Failed to connect or hit timeout.");
    // 如果超時，可以選擇重啟或進入離線模式，這裡選擇重啟
    delay(3000);
    ESP.restart();
  }

  Serial.println("WiFi: Connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loopWiFi() {
  // 檢查重置按鈕
  if (RESET_BTN_PIN >= 0) {
    static unsigned long pressStart = 0;
    if (digitalRead(RESET_BTN_PIN) == LOW) {
      if (pressStart == 0) {
        pressStart = millis();
      } else if (millis() - pressStart > RESET_HOLD_MS) {
        Serial.println("WiFi: Resetting settings and restarting...");
        WiFiManager wm;
        wm.resetSettings();
        delay(1000);
        ESP.restart();
      }
    } else {
      pressStart = 0;
    }
  }

  // WiFiManager 內部會處理自動重連 (WiFi.setAutoReconnect(true) 是預設)
  // 我們只需要在主 loop 確保 WiFi.status() 即可
}

// 提供給 arduino_draft.ino 呼叫的檢查函式替代原有的 ensureWiFiConnected
void checkWiFiConnection() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println(
        "WiFi: Connection lost. WiFiManager/ESP32 will handle reconnection.");
  }
}

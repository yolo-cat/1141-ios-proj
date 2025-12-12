# ESP32 Stage-1 開發步驟

依照 `esp32/AGENTS.md` 拆解的可執行清單。

1. **環境與套件**：使用 Arduino IDE 或 PlatformIO，安裝 ESP32 board support、`WiFi.h`、`HTTPClient`、`ArduinoJson`、`DHTesp`。
2. **機密設定**：建立未版控的 `secrets.h`（或等效環境設定），並將檔名加入 `.gitignore`，使用 `secrets.h.template` 做為占位格式，提供 `WIFI_SSID`、`WIFI_PASSWORD`、`SUPABASE_URL`、`SUPABASE_ANON_KEY`。主程式只引用占位符，避免提交實際值。
3. **感測初始化**：在 `setup()` 以 GPIO 15 建立 DHT11，序列埠輸出啟動狀態。`arduino_draft.ino` 內的 `DEMO_MODE` 切換週期：標準模式 5 分鐘、Demo 模式 10 秒。
4. **讀值與監控**：在 `loop()` 先檢查 Wi-Fi，斷線即自動重連。讀取 DHT11，若溫濕度為 NaN 直接跳過並記錄。
5. **資料上傳**：使用 `HTTPClient` POST 至 `<SUPABASE_URL>/rest/v1/readings`，Header 包含 `apikey` 與 `Authorization: Bearer <anon key>`，Body 為含 `device_id/temperature/humidity` 的 JSON 物件。設定 `Content-Type: application/json` 與 `Prefer: return=minimal`。TLS 可使用 `SUPABASE_ROOT_CA`，或於測試時將 `ALLOW_INSECURE_TLS=true`。
6. **驗證**：在 Demo 模式檢查序列埠輸出（連線、NaN 跳過、HTTP 狀態碼）。可比對 Supabase 資料表新增行數，確保每次成功上傳。

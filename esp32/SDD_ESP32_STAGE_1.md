# SDD_ESP32_STAGE_1

Stage 1 軟體設計說明（SDD）。需求來源：`PRD_ESP32_STAGE_1.md` / `PRD_STAGE1.md`，設計摘要：`DESIGN_ESP32_STAGE_1.md`，任務：`TASKS_ESP32_STAGE_1.md`。

## 目標
- 以 ESP32 + DHT11（GPIO 15）週期性讀值（標準 300000ms、Demo 10000ms），若 NaN 則跳過。
- 透過 HTTP POST 將 `device_id | temperature | humidity` 送至 `<SUPABASE_URL>/rest/v1/readings`，Header 含 `api key`、`Authorization: Bearer <anon key>`、`Content-Type: application/json`、`Prefer: return=minimal`。
- 憑證與 Wi-Fi 資訊由未版控的 `secrets.h` 提供。

## 模組與責任
- **Config**：`secrets.h` 暴露 `WIFI_SSID`、`WIFI_PASSWORD`、`SUPABASE_URL`、`SUPABASE_ANON_KEY`。程式只引用占位符，不含實際值。
- **Wi-Fi Manager**：開機連線、迴圈偵測斷線並自動重連；序列埠輸出狀態。
- **Sensor**：`DHTesp` 於 `setup()` 以 GPIO 15 初始化；讀值函式回傳溫/濕度與狀態。任何 NaN 需記錄並跳過上傳。
- **Scheduler**：依模式（Demo/標準）控制讀值與上傳節奏；可透過常數或編譯旗標切換。
- **Payload Builder**：組合 JSON `{"device_id": ..., "temperature": ..., "humidity": ...}`；固定小數格式即可，無需科學記號。
- **Uploader**：`HTTPClient` + `ArduinoJson` POST；檢查 HTTP 狀態碼（201/204）並在序列埠紀錄成功/失敗。

## 測試對應（TDD 入口）
- 邏輯層測試位於 `esp32/test/stage_1/test_stage1.cpp`（Unity）。涵蓋：
  - `isValidReading`：NaN 濾除。
  - `intervalMs`：Demo/標準週期（10000ms/300000ms）。
  - `buildPayload`：JSON 欄位/格式。
  - `canUpload`：需 Wi-Fi 連線且讀值有效才上傳。
- 硬體與 HTTP 實作需以序列埠與 Supabase 表驗證，測試檔不模擬 Wi-Fi/DHT/HTTP。

## 完成度現況（本次迭代）
- 測試方案與邏輯測試腳本：**已提供**（`TEST_ESP32_STAGE1.md`、`test/stage_1/test_stage1.cpp`）。未執行實測。
- 韌體主程式：**未符合 Stage 1**（`arduino_draft.ino` 為 Blynk 範例，尚未改寫成 Supabase 版）。
- 待辦：依上述模組落地 Wi-Fi/DHT/HTTP 流程，串接邏輯層函式並以序列埠 + Supabase 表實測。

## 參考
- 需求：`PRD_ESP32_STAGE_1.md`
- 設計：`DESIGN_ESP32_STAGE_1.md`
- 任務：`TASKS_ESP32_STAGE_1.md`
- 測試：`TEST_ESP32_STAGE1.md`、`test/stage_1/test_stage1.cpp`

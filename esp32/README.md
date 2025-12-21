# ESP32 (Arduino)

Stage-1 firmware workspace for sending DHT11 readings to Supabase.

- 需求：`PRD_ESP32_STAGE_1.md`（完整需求見 `../PRD_STAGE1.md`）。
- 設計與守則：`AGENTS.md`、`DESIGN_ESP32_STAGE_1.md`。
- 可執行步驟：`TASKS_ESP32_STAGE_1.md`（GPIO 15、5 分鐘周期，Demo 10 秒）。
- Stage 1 韌體：`arduino_draft.ino`（預設 5 分鐘讀值，`DEMO_MODE=true` 時 10 秒）。
- 機密範本：`secrets.h.template`（自建 `secrets.h` 並加入 `.gitignore`）。

## 重要更新：WiFi 設定方案 (WiFiManager)

本專案已改用 **WiFiManager** 方案，不再需要在 `secrets.h` 中寫死 WiFi 資訊。程式碼拆分為 `arduino_draft.ino` (主邏輯) 與 `wifi_config.ino` (WiFi 管理)。

### 首次設定步驟

1. 燒錄程式碼至 ESP32。
2. 使用手機搜尋 WiFi，連線至名為 **`ESP32-Setup`** 的熱點。
3. 連線後會自動跳出（或手動開啟 `192.168.4.1`）WiFi 設定網頁。
4. 選擇你的 WiFi SSID 並輸入密碼，儲存後 ESP32 會自動重啟並連線。

### 重置 WiFi 設定

- **按鈕教學**：長按 **GPIO 4** 接地的按鈕 3 秒，裝置會清除儲存的 WiFi 並重新進入設定模式（熱點模式）。

## 快速測試

1. 將 `secrets.h.template` 複製為 `secrets.h`，填入 Supabase URL/anon key 與 `DEVICE_ID`。
2. 依需求調整 `DEMO_MODE`（預設 `false` 為 5 分鐘；Demo 10 秒），燒錄專案（包含兩個 `.ino` 檔案）。
3. 依上述「首次設定步驟」完成 WiFi 連線。
4. 以序列埠監看：可見連線成功後開始讀值上傳，Supabase `readings` 表應新增對應行。

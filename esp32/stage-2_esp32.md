# ESP32 專案開發指引（Stage 2 - 進階與優化）

本文件承接 Stage 1 基礎，整合了 Stage 2 的進階需求、分層架構設計與開發規範。Stage 2 的核心目標在於 **提高部署彈性 (WiFiManager)**、**優化功耗 (Deep Sleep)** 與 **模組化程式碼結構**。

---

## 1. 需求描述 (Product Requirements)

### 部署彈性與設定

- **WiFi 設定**: 移除硬編碼的 SSID/Password。改用 **WiFiManager** 方案。
  - 找不到 WiFi 時自動開啟熱點 `ESP32-Setup`。
  - 提供 Captive Portal 網頁設定介面。
  - 支援硬體按鈕 (GPIO 4) 長按 3 秒重置 WiFi 設定。

### 電源優化 (Power Management)

- **週期性睡眠**:
  - **標準模式**: 資料上傳後進入 **Deep Sleep (深度睡眠)** 5 分鐘。
  - **Demo 模式**: 為便利除錯，可維持 `delay()` 10 秒之循環或縮短睡眠時間。
- **喚醒機制**: 使用 Timer 喚醒。

### 資料傳輸

- 維持 Stage 1 的 Supabase REST API 格式。
- 增加連線狀態紀錄，於序列埠輸出連線耗時與上傳成功率。

---

## 2. 設計架構 (Design Overview)

### 模組化目錄結構

為提高可讀性，Stage 2 捨棄單一巨大的 `.ino` 檔案，改為多檔案結構：

- `arduino_stage2.ino`: 主程式入口，負責 Setup 與 Loop 狀態調度。
- `wifi_config.ino`: 封裝 WiFiManager、連線監測與重置按鈕邏輯。
- `sensor_handler.ino` (建議): 專門負責 DHT11 讀取與數據校驗。

### 系統行為流程

1. **冷啟動 (Cold Boot)**: 初始化硬體 -> 檢查重置按鈕。
2. **網路建立**: 執行 `WiFiManager` 自動連線或進入 AP 模式。
3. **任務執行**: 讀取感測器 -> 組裝 JSON -> HTTPS POST 至 Supabase。
4. **進入睡眠**: 根據模式決定進入 `esp_deep_sleep_start()` 或維持 `loop()`。

---

## 3. AI 開發指引 (Agent Guidelines)

### 核心原則

- **模組化隔離**: 不要將 WiFi 設定邏輯寫在主程式中，應透過 `extern` 呼叫 `wifi_config.ino` 內的介面。
- **狀態感知**: 辨識 ESP32 的喚醒原因（例如：Timer 喚醒或按鈕喚醒）。
- **非阻塞設計**: 在 Portal 設定期間，確保不會因為長時間等待而導致看門狗計時器 (WDT) 觸發。

### 開發守則

- **NVS 應用**: 善用 ESP32 的 Non-Volatile Storage (NVS) 存儲 WiFi 設定與裝置狀態。
- **安全性**: `secrets.h` 僅保留 API 金鑰，不再存放 WiFi 資訊。
- **外部介面宣告**: 跨檔案呼叫函式前，務必在主檔中使用 `extern` 宣告介面。

---

## 4. 開發步驟與規格 (Tasks & Specifications)

### Step 1: 專案結構拆分

- 建立 `wifi_config.ino`。
- 修改 `arduino_stage2.ino` 以引用外部 WiFi 介面：
  - `extern void setupWiFi();`
  - `extern void loopWiFi();`

### Step 2: 實作 WiFiManager

- 引用 `WiFiManager.h` (tzapu)。
- 設定 `wm.autoConnect("ESP32-Setup")`。
- 實作 GPIO 4 中斷或輪詢邏輯，觸發 `wm.resetSettings()`。

### Step 3: Deep Sleep 整合

- 實作 `enterDeepSleep(unsigned long seconds)`。
- 注意：Deep Sleep 喚醒後會從 `setup()` 重新執行，全域變數會消失。若需記憶狀態需使用 `RTC_DATA_ATTR`。

### Step 4: 驗證規格

- **連線測試**: 驗證無已知 WiFi 時是否能正確彈出設定網頁。
- **功耗測試**: 透過序列埠觀察「進入睡眠」之訊息，並確認喚醒後能正確再次連線。
- **穩定性測試**: 模擬 Supabase API 回傳 401/500 等錯誤碼的處理機制。

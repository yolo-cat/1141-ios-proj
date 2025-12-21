# ESP32 (Arduino) - Stage 2

這是支援 ESP32 資料上傳至 Supabase 的 Stage 2 韌體工作區。本階段重點在於 **部署彈性 (WiFiManager)** 與 **功耗優化 (Deep Sleep)**。

## 文件指南

- **開發總綱**: `AGENTS.md` (Stage 1 基礎規則)。
- **Stage 1 工具盒**: `stage-1_esp32.md`（基礎感測與上傳邏輯）。
- **Stage 2 進階指引**: `stage-2_esp32.md` (**當前核心目標**：WiFiManager, Deep Sleep, 模組化)。

## 核心設計說明

### 1. WiFi 設定方案 (WiFiManager)

本專案已移除硬編碼 WiFi 資訊，改用 **WiFiManager** 動態設定：

- **首次連線**: 搜尋並連線熱點 `ESP32-Setup`，於彈出的網頁設定 WiFi。
- **重置設定**: 長按 **GPIO 4** 按鈕 3 秒，裝置將清除 WiFi 設定並重啟。

### 2. 韌體結構 (Modular structure)

程式碼已拆分為多檔案結構以利維護，燒錄時請確保包含 `arduino_stage2/` 下所有檔案：

- `arduino_stage2.ino`: 主程式與任務調度。
- `wifi_config.ino`: WiFi 管理與重置邏輯。

### 3. 功耗優化 (Deep Sleep)

- **標準模式**: 資料上傳後進入 **Deep Sleep** 5 分鐘，以節省電力。
- **Demo 模式**: 可切換為每 10 秒讀取一次的循環除錯模式。

## 快速測試步驟

1. 安裝必要庫：`WiFiManager` (tzapu), `ArduinoJson`, `DHTesp`, `HTTPClient`。
2. 將 `secrets.h.template` 複製到 `arduino_stage2/secrets.h`，填入 Supabase URL/Key 與 `DEVICE_ID`。
3. 使用 Arduino IDE 開啟 `arduino_stage2/arduino_stage2.ino` 並燒錄。
4. 依「WiFi 設定方案」完成網路設定，並透過序列埠監看上傳狀態。

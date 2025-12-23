/\*

- File: esp32/AGENTS.md
- Purpose: ESP32 Firmware Runtime Status and AI Collaboration Protocol
- Architecture: Arduino/C++, ESP32, DHT11, Supabase REST
- AI Context: Firmware-specific constraints and sensor data integrity.
  \*/

# ESP32 開發指引 (Stage 2)

本檔案紀錄 ESP32 韌體的開發狀態與自動化指令。請嚴格遵守 [GEMINI.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/GEMINI.md) 協議。

## 🎯 當前進度 (Done)

- ✅ **Stage 1: MVP Firmware Implementation**
  - 使用 ESP32 + DHT11 讀取溫濕度。
  - 實作 Supabase REST API 上傳邏輯 (JSON format)。
  - 支援 `DEMO_MODE` 切換上傳週期 (5 mins / 10 secs)。
  - Wi-Fi 自動重連與 HTTP 基本錯誤處理。

## 📝 關鍵開發決策 (History)

- **2025-12-23**: 確認 Stage 1 基礎韌體已穩定，可由 REST API 成功將數據推送至 `readings` 資料表。
- **2025-12-23**: `arduino_stage2.ino` 已根據開發需求將 `DEMO_MODE` 預設設為 `true`。

## 🚧 下一步 (Next Steps)

- [ ] **Stage 2: Advanced Reliability**
  - 實作 OTA (Over-the-Air) 更新支援。
  - 優化 TLS 憑證管理，從 `secrets.h` 動態注入。
  - 導入 Deep Sleep 模式以優化功耗（視硬體供電情況）。
- [ ] **Local Logging**: 導入更完善的 Serial Debugging 協定，方便 AI 診斷連線問題。

---

## 快速起手指令 (Prompt Samples)

- **Sensor Handler**:
  > "Modify the DHT11 reading logic to include a simple moving average filter (3 samples) to reduce sensor noise before uploading to Supabase."
- **HTTP Error Debugger**:
  > "Analyze the HTTP POST logic and add specific handling for Supabase 401 (Unauthorized) errors, including a Serial print of the expected API Key format for verification."

---

## 📂 檔案架構

- `arduino_stage2.ino`: 主韌體代碼。
- `secrets.h`: 金鑰與連線資訊 (未版本控制)。

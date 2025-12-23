# ESP32 韌體概觀 (Stage 2)

本目錄包含 Pu'er Sense 專案的 ESP32 韌體程式碼。目前已進入 **Stage 2 (Enhanced Reliability)**。

## 📍 核心索引 (Index)

- **開發日誌**: [`AGENTS.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/esp32/AGENTS.md)
- **主程式碼**: [`arduino_stage2/arduino_stage2.ino`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/esp32/arduino_stage2/arduino_stage2.ino)
- **Stage 1 備份**: [`stage-1_esp32.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/esp32/stage-1_esp32.md)

## 🚀 Stage 2 核心功能

### 1. 動態網路設定 (WiFiManager)

已移除硬編碼的 WiFi 資訊。設備啟動後若無連網紀錄，將開啟 `ESP32-Setup` 熱點。用戶可透過手機連網並設定目標 WiFi。

### 2. 功耗管理 (Deep Sleep)

為優化電池壽命，設備在資料上傳成功後會進入 **Deep Sleep** 5 分鐘。Demo 模式下可切換為連續讀取。

### 3. 模組化結構

程式碼按功能模組化（如 WiFi 管理、感測器讀取、API 傳輸），提升維護效率。

## 🛠️ 快速起手步驟

1. **環境準備**: 安裝 `WiFiManager` (tzapu), `ArduinoJson`, `DHTesp` 函式庫。
2. **金鑰設定**: 將 `secrets.h.template` 複製並命名為 `secrets.h`，填入 Supabase URL/Key。
3. **燒錄**: 使用 Arduino IDE 或 PlatformIO 燒錄 `arduino_stage2` 程式。
4. **配網**: 連接 `ESP32-Setup` 熱點完成第一次連網設定。

---

> [!CAUTION]
> **安全提示**：請勿將包含真實 WiFi 或 API Key 的 `secrets.h` 提交至版本控制系統。

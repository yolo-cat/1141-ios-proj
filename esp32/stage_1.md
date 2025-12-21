# ESP32 專案開發指引（Stage 1）

本文件整合了 Stage 1 的需求、設計、開發規範與任務，採用 **SDD (Spec-Driven Development, 規格驅動開發)** 模式，確保開發過程符合預期規格與介面定義。

---

## 1. 需求描述 (Product Requirements)

摘錄自 Stage 1 的核心需求，旨在建立基礎的環境感測與資料上傳機制。

### 硬體規格

- **控制器**: ESP32-WROOM-32E
- **感測器**: DHT11 (接腳：GPIO 32，依電路圖為準)

### 運作週期

- **標準模式**: 每 5 分鐘讀取一次。
- **Demo 模式**: 每 10 秒讀取一次。
- **異常處理**: 若讀值為 `NaN`，應跳過該次資料上傳。

### 資料傳輸規格

- **傳輸協議**: REST API (POST)
- **目標端點**: `<SUPABASE_URL>/rest/v1/readings`
- **JSON 欄位位元組**:
  ```json
  {
    "device_id": "tea_room_01",
    "temperature": 25.5,
    "humidity": 60.0
  }
  ```

---

## 2. 設計架構 (Design Overview)

### 系統流程

1. **啟動階段**: 初始化序列埠 (Serial)、Wi-Fi 連線與 DHT 感測器。
2. **連路維護**: `loop()` 中持續監測 Wi-Fi 狀態，斷線時自動啟動重連機制。
3. **感測循環**: 根據設定的開發週期 (Standard/Demo) 觸發讀取。
4. **資料組裝**: 使用 `ArduinoJson` 封裝感測數據。
5. **安全傳輸**: 透過 `HTTPClient` 以 TLS 加密上傳至 Supabase。

### 安全設計

- **機密資訊隔離**: 所有金鑰（Wi-Fi SSID、密碼、Supabase Key）必須存放於 `secrets.h` 並排除在版本控制之外。
- **憑證驗證**: 預設使用 `SUPABASE_ROOT_CA`；測試環境可允許 `ALLOW_INSECURE_TLS=true`。

---

## 3. AI 開發指引 (Agent Guidelines)

本章節指導 AI Agent 如何在不破壞現有架構的情況下進行修改。

### 核心原則

- **最小改動**: 僅修改必要的代碼邏輯，避免大規模重構。
- **一致性**: 確保與 `PRD` 與 `DESIGN` 規格同步。
- **規格優先**: 在實作前，應先核對 API 欄位與硬體接腳定義。

### 開發守則

- **日誌記錄**: 關鍵步驟（連線、上傳失敗、NaN 跳過）需有清楚的序列埠輸出。
- **健壯性**: 必須處理 TLS 握手失敗與網路連線異常。
- **標頭設定**: API 請求必須包含以下 Header：
  - `apikey`: `<anon key>`
  - `Authorization`: `Bearer <anon key>`
  - `Content-Type`: `application/json`
  - `Prefer`: `return=minimal`

---

## 4. 開發步驟與規格 (Tasks & Specifications)

此章節為 SDD 模式的核心執行步驟。

### Step 1: 環境整備與擴展

- **依賴庫**: `WiFi.h`, `HTTPClient`, `ArduinoJson`, `DHTesp`。
- **定義檔**: 建立 `secrets.h`（範例見 `secrets.h.template`）。

### Step 2: 韌體初始化 (Setup)

- 初始化序列埠 (115200 baud)。
- 配置啟動 DHT11 於指定 GPIO。
- 連線 Wi-Fi 並檢查狀態。

### Step 3: 感測與上傳邏輯 (Loop)

- **週期控制**: 透過常數或標記位切換 `DELAY_MS`。
- **讀取校驗**:
  - `if (isnan(t) || isnan(h))` -> Log & Skip.
- **POST 實作**:
  - 建立 `HTTPClient` 實例。
  - 序列化 JSON payload。
  - 發送請求並處理 Response Code (預期 201)。

### Step 4: 驗證規格 (Validation)

- **單元測試**: 確認 `secrets.h` 正確注入。
- **整合測試**: 觀察序列埠輸出，確保資料成功寫入 Supabase 表格。
- **邊界測試**: 模擬 Wi-Fi 斷開，驗證自動重連功能。

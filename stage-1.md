# Stage 1 Archive: TeaWarehouse-MVP (MVP 階段)

本檔案為 Stage 1 (MVP 階段) 的完整文檔存檔，包含產品需求 (PRD)、高層設計 (Design)、任務清單 (Tasks) 以及 AI Agent 啟動指令。

---

## 1. PRD_STAGE1.md (產品需求文件)

# PRD: 普洱茶倉環境監控系統 (MVP)

### 1. 專案概述 (Project Overview)

本專案為 iOS 課程期末專題。目標是開發一套物聯網系統，利用 ESP32 採集溫濕度數據，透過 Supabase 進行雲端儲存與即時同步，並在 iOS App 上即時呈現數據與歷史圖表。

- **專案代號**: TeaWarehouse-MVP
- **核心價值**: 即時性 (Real-time)、原生體驗 (Native iOS)、資料視覺化 (Data Viz)。

### 2. 技術堆疊 (Tech Stack)

- **Hardware / Firmware**: ESP32-WROOM-32E, DHT11, C++ (Arduino Framework)
- **Backend (BaaS)**: Supabase (PostgreSQL, Realtime, Auth, RLS)
- **Frontend (Mobile)**: iOS 17+, Swift (SwiftUI, supabase-swift, Swift Charts)

### 3. 資料庫設計 (Database Schema) - Table: `readings`

| Column Name   | Data Type     | Description         |
| :------------ | :------------ | :------------------ |
| `id`          | `int8`        | PK, Identity        |
| `created_at`  | `timestamptz` | now()               |
| `device_id`   | `text`        | e.g., "tea_room_01" |
| `temperature` | `float4`      | 攝氏溫度            |
| `humidity`    | `float4`      | 相對濕度            |

**RLS Policies**: INSERT (anon), SELECT (authenticated)

### 4. 硬體端規格 (ESP32 Firmware Specs)

- 連網邏輯：自動重連 Wi-Fi
- 感測邏輯：每 5 分鐘 (Demo 10秒) 讀取 DHT11
- API 格式：POST JSON 至 Supabase REST Endpoint

### 5. iOS App 功能需求

- **驗證**: Supabase Auth (Email/Password)
- **Dashboard**: 訂閱 Realtime `INSERT`，超過臨界值 (Temp > 30°C, Hum > 70%) 震動與通知。
- **History**: 使用 Swift Charts 繪製 24 小時趨勢。

---

## 2. DESIGN_STAGE1.md (高層設計)

此文件提供 Stage 1 的高層設計索引：

- Backend：`supabase/DESIGN_SUPABASE_STAGE_1.md`
- Firmware：`esp32/DESIGN_ESP32_STAGE_1.md`
- iOS：`ios/DESIGN_IOS_STAGE_1.md`

**整體流程**：ESP32 -> Supabase REST -> Realtime -> iOS App

---

## 3. TASKS_STAGE1.md (任務清單)

依 PRD 執行 Stage 1 工作：

- Supabase：`supabase/TASKS_SUPABASE_STAGE_1.md`
- ESP32：`esp32/TASKS_ESP32_STAGE_1.md`
- iOS：`ios/TASKS_IOS_STAGE_1.md`

---

## 4. stage_1_prompt.md (AI Agent 啟動指令)

### 給 AI Coding Agent 的啟動指令 (Prompt)

- **Supabase**: "I am building an IoT project with Supabase. Please generate the SQL to create a table named `readings`..."
- **ESP32**: "Write an Arduino sketch for ESP32 with DHT11 connected to GPIO 32..."
- **iOS**: "Create a SwiftUI ViewModel named `SensorViewModel` using the `supabase-swift` SDK..."

---

## 5. README.md (Stage 1 Version)

# TeaWarehouse-MVP 文檔索引（Stage 1）

子專案入口：

- `supabase/README.md`
- `esp32/README.md`
- `ios/README.md`

---

_End of Stage 1 Archive_

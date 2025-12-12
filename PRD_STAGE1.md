# PRD: 普洱茶倉環境監控系統 (MVP)

## 1\. 專案概述 (Project Overview)

本專案為 iOS 課程期末專題。目標是開發一套物聯網系統，利用 ESP32 採集溫濕度數據，透過 Supabase 進行雲端儲存與即時同步，並在 iOS App 上即時呈現數據與歷史圖表。

  * **專案代號**: TeaWarehouse-MVP
  * **核心價值**: 即時性 (Real-time)、原生體驗 (Native iOS)、資料視覺化 (Data Viz)。

## 2\. 技術堆疊 (Tech Stack)

  * **Hardware / Firmware**:
      * MCU: ESP32-WROOM-32E
      * Sensor: DHT11 (Temperature & Humidity)
      * Language: C++ (Arduino Framework)
      * Libraries: `WiFi.h`, `HTTPClient.h`, `ArduinoJson`, `DHT sensor library`
  * **Backend (BaaS)**:
      * Platform: **Supabase**
      * Database: PostgreSQL
      * Features: Realtime, Auth, Row Level Security (RLS)
  * **Frontend (Mobile)**:
      * OS: iOS 17+
      * Language: Swift 5.9+
      * Framework: **SwiftUI**
      * Libraries: `supabase-swift` (Official SDK), `Swift Charts`

## 3\. 資料庫設計 (Database Schema)

**Table Name**: `readings`

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `int8` | Primary Key, Identity | 唯一識別碼 |
| `created_at` | `timestamptz` | Default: `now()` | 數據上傳時間 |
| `device_id` | `text` | Not Null | 裝置/茶倉識別碼 (e.g., "warehouse\_A") |
| `temperature` | `float4` | Not Null | 攝氏溫度 (°C) |
| `humidity` | `float4` | Not Null | 相對濕度 (%) |

**RLS Policies (Row Level Security)**:

1.  **INSERT**: 開放給擁有 `anon_key` 的角色 (允許 ESP32 寫入)。
2.  **SELECT**: 僅限 `authenticated` (已登入) 使用者讀取。

## 4\. 硬體端規格 (ESP32 Firmware Specs)

  * **連網邏輯**:
      * 啟動時連接指定 Wi-Fi (SSID/Password)。
      * 若斷線需執行自動重連 (Auto-reconnect)。
  * **感測邏輯**:
      * 每 **5分鐘** (Demo 模式改為 10秒) 讀取一次 DHT11。
      * 若讀取失敗 (NaN)，該次不進行上傳。
  * **API 請求格式**:
      * **URL**: `https://<PROJECT_REF>.supabase.co/rest/v1/readings`
      * **Method**: `POST`
      * **Headers**:
          * `apikey`: `<SUPABASE_ANON_KEY>`
          * `Authorization`: `Bearer <SUPABASE_ANON_KEY>`
          * `Content-Type`: `application/json`
          * `Prefer`: `return=minimal`
      * **Body (JSON)**:
        ```json
        {
          "device_id": "tea_room_01",
          "temperature": 25.5,
          "humidity": 62.0
        }
        ```
      * 
## 5\. iOS App 功能需求 (Frontend Requirements)

App 架構需採用 MVVM 模式。

### 5.1 驗證模組 (Authentication)

  * 使用 Supabase Auth (Email/Password)。
  * 提供「登入」與「註冊」畫面。
  * 登入成功後保存 Session，進入主畫面。

### 5.2 主儀表板 (Dashboard View) - **Core Feature**

  * **數據來源**: 訂閱 `readings` 資料表的 Realtime 事件 (`INSERT`)。
  * **UI 元件**:
      * 頂部顯示當前 `device_id`。
      * 兩個大型卡片顯示**最新**的「溫度」與「濕度」。
      * 數據需隨 Realtime 事件觸發而即時跳動更新。
  * **本地告警 (Local Notification)**:
      * 若收到新數據：Temp \> 30°C 或 Humidity \> 70%，觸發手機震動與通知。

### 5.3 歷史圖表 (History View)

  * **數據來源**: 透過 Supabase Client `from("readings").select()` 拉取資料。
  * **查詢條件**: `.order("created_at", ascending: true).limit(288)` (約過去 24 小時數據)。
  * **UI 元件**:
      * 使用 **Swift Charts** 繪製兩條折線圖 (溫度-紅線, 濕度-藍線)。
      * X 軸為時間，Y 軸為數值。

## 6\. 專案檔案結構建議 (File Structure)

*(提供給 AI Agent 參考以建立整潔的專案)*

```text
TeaMonitorApp/
├── Models/
│   ├── Reading.swift        // Codable struct matching DB schema
├── ViewModels/
│   ├── AuthViewModel.swift  // Handle Login/Sign up
│   ├── SensorViewModel.swift // Handle Realtime subscription & Data fetching
├── Views/
│   ├── LoginView.swift
│   ├── DashboardView.swift  // Real-time cards
│   ├── HistoryChartView.swift // Swift Charts implementation
├── Managers/
│   ├── SupabaseManager.swift // Singleton for Supabase client
├── TeaMonitorApp.swift      // Entry point
```

-----
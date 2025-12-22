# iOS DashboardView 設計規格 (Stage 2)

## 規格說明

### Header (頂部導航)

- **左側**：顯示 App 名稱「Pu'er Sense」，使用 `font(.headline).tracking(2)`。
- **中間**：倉庫切換器 (Menu 樣式)，顯示當前位置 (如「Menghai Depot」)，點擊可切換。
- **右側**：用戶頭像按鈕，採用 `Circle()` 裁剪，背景帶有 `UltraThinMaterial` 效果。

### Main Area (主要內容)

- **Bento Grid (便當佈局)**：
  - **即時數據卡片**：顯示當前最新的一筆環境數據。
    - **內容**：包含更新時間 (`HH:mm`)、溫度 (`temperature`)、濕度 (`humidity`)。
    - **佈局**：垂直排列，圖標 (`thermometer`, `drop`) 置於數據左側，與時間圖標 (`clock`) 靠左對齊。
    - **來源**：`DashboardViewModel.currentReading` (@[App/ViewModels/DashboardViewModel.swift])。
  - **異常警報卡片**：顯示當前系統警報狀態。

#### 異常警報卡片規格 (Alert Card Spec - Ambient Aura)

- **設計哲學**: **Emotional (情緒化)**，讓狀態成為背景氛圍，而非單純的標籤。
- **背景視覺 (Ambient Background)**:
  - **Normal**: `LinearGradient` (Blue/Mint, opacity 0.1)，模擬清新空氣。
  - **Alert**: `LinearGradient` (Red/Orange, opacity 0.15~0.2)，模擬警示氛圍。
- **主體內容**:
  - **Layout**: 居中或左對齊的簡潔佈局，留白呼吸感。
  - **Icon**: 使用 `.hierarchical` 渲染模式的 `shield.fill` 或 `exclamationmark.triangle.fill`。
  - **Typography**: 標題與描述採用 `.design(.rounded)`，顏色隨背景深淺自動調整 (主要為深色文字搭配淡色背景)。
- **互動**: 點擊可展開查看詳情 (預留)。
- **動畫**: 狀態切換時背景顏色平滑過渡 (`.animation(.easeInOut(duration: 0.5))`)。

---

- **Unified Monitoring (整合監控區)**：
  - 使用 `TabView` 進行多裝置分頁。
  - **整合卡片 (UnifiedClimateCard)**：
    - **架構**：採用 `ChartContainer` pattern，統一處理標題、圖標與外框樣式 (參考 React `ChartContainer`)。
    - **交互**：支援 **拖曳手勢 (Drag Gesture)** 查看特定時間點的數值 (Chart Tooltip)。
    - **Header**：裝置名稱、狀態 (Online 綠燈/Offline 灰燈)、電量/WiFi 狀態。
    - **圖表模式** (Default)：
      - **Temperature**：橙色漸層 Area + Line。
      - **Humidity**：藍色虛線 Line。
      - **指標**：左上方顯示當前 (或選中) 的大數值 (Big Metrics)。
      - **X 軸**：顯示時間 (H:mm)，自動適應間距。
    - **列表模式**：
      - 點擊右上方圖示切換。
      - 顯示詳細歷史數據列表 (Newest First)。
      - **佈局優化**：卡片採用 **Top Alignment (.frame(alignment: .top))** 以確保模式切換時標題位置固定，並向下擴展。

### Footer (底部功能)

- 膠囊狀按鈕 (Capsule)，固定於底部，引導至「Warehouse Management」。

### 視覺風格

- **Digital Wabi-Sabi**：背景色 `Color("Stone50")`，圓角 `.cornerRadius(32)`，細微陰影 `.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)`。

---

## 實作參考

本視圖與 `DashboardViewModel` 深度互動，以下為關鍵代碼片段與後端數據整合指引。

### 1. 視圖實作 (DashboardView.swift)

```swift
// DashboardView.swift 中的 Bento Grid 與卡片調用
private var swipeableCardsSection: some View {
    TabView(selection: $activeTab) {
        ForEach(Array(activeDeviceIds.enumerated()), id: \.offset) { index, deviceId in
            UnifiedClimateCard(
                deviceId: deviceId,
                location: deviceInfo?.location ?? "Unknown",
                status: deviceInfo?.status ?? .offline,
                battery: deviceInfo?.battery ?? 0,
                readings: groupedHistory[deviceId] ?? []
            )
            .tag(index)
        }
    }
}

// UnifiedClimateCard 歷史列表排序邏輯
private func deviceContentView(readings: [Reading]) -> some View {
    if showList {
        let sortedData = readings.sorted { $0.createdAt > $1.createdAt } // Newest First
        // ...渲染內容...
    } else {
        let chartData = readings.sorted { $0.createdAt < $1.createdAt } // Oldest First (Timeline)
        // ...渲染圖表...
    }
}
```

### 2. 數據解碼 (SupabaseManager.swift)

為確保 `created_at` (timestamptz) 正確解析，必須在 `JSONDecoder` 中設定 `.iso8601` 策略：

```swift
private static var supabaseDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}

// 訂閱用法
let row = try insertion.decodeRecord(as: ReadingRow.self, decoder: SupabaseManager.supabaseDecoder)
```

---

## Backend & Database Context (AI Agents Only)

### 資料庫架構 (readings 表)

| 欄位名        | 資料類型    | 說明                 |
| :------------ | :---------- | :------------------- |
| `id`          | bigint      | 主鍵                 |
| `created_at`  | timestamptz | ISO8601 格式更新時間 |
| `device_id`   | text        | 設備標籤 (如 ESP-01) |
| `temperature` | real        | 溫度數值 (Celsius)   |
| `humidity`    | real        | 濕度數值 (%)         |

### MCP 強化理解方案

AI AGENTS 可使用 `supabase-mcp-server` 進行即時驗證：

- **檢查即時數據**：
  ```sql
  -- 使用 mcp_supabase-mcp-server_execute_sql (Project ID: fvovzbskokfqtzcyidqy)
  SELECT * FROM readings ORDER BY created_at DESC LIMIT 5;
  ```
- **檢查表格結構**：
  ```sql
  SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'readings';
  ```

---

---

- **Design Pattern**: MVVM + Observation (SwiftUI 17+)
- **View**: `DashboardView` (@[App/Views/DashboardView.swift])
  - `headerView`: 頂部導航
  - `bentoGrid`: 即時數據與警報
  - `swipeableCardsSection`: 多裝置整合監控分頁
- **ViewModel**: `DashboardViewModel` (@[App/ViewModels/DashboardViewModel.swift])
  - `startListening()`: 啟動 Realtime 監聽
  - `checkAlert(for:)`: 警報判斷邏輯
  - `fetchHistory(limit:)`: 獲取歷史紀錄
- **Dependency**: `SupabaseManager` (@[App/Managers/SupabaseManager.swift]) 為資料流核心。

## 注意事項

1. **ViewModel 生命週期**：請確保在 `onAppear` 呼叫 `startListening()` 與 `fetchDefaultHistory()`。
2. **數據流**：所有 UI 狀態均由 `DashboardViewModel` 的屬性驅動，遵循 **Single Source of Truth**。
3. **列表效能**：`UnifiedClimateCard` 在渲染大數據量歷史列表時，應監控內存，必要時使用 `LazyVStack` 或分頁加載。
4. **離線處理**：若 `SupabaseManager` 連線中斷，View 應顯示適當的離線佔位符 (已整合至 `UnifiedClimateCard` 標題)。

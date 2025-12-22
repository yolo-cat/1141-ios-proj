# iOS DashboardView 設計規格 (Stage 2)

## 規格說明

### Header (頂部導航)

- **左側**：顯示 App 名稱「Pu'er Sense」，使用 `font(.headline).tracking(2)`。
- **中間**：倉庫切換器 (Menu 樣式)，顯示當前位置 (如「Menghai Depot」)，點擊可切換。
- **右側**：用戶頭像按鈕，採用 `Circle()` 裁剪，背景帶有 `UltraThinMaterial` 效果。

### Main Area (主要內容)

- **Bento Grid (便當佈局)**：
  - **即時數據卡片**：顯示當前溫度與濕度。數據來源為 `DashboardViewModel.currentReading`：
    - 採用最近一筆數據，並顯示其更新時間 (`createdAt`)。
  - **異常警報卡片**：顯示當前警報狀態。(詳見下文 [異常警報卡片設計方案](#異常警報卡片設計方案-design-proposals))
    - 預設採用 **方案 B (Dynamic Surface)** 進行實作。

### 異常警報卡片設計方案 (Design Proposals)

為提升 Stage 2 儀表板的視覺層次與資訊傳達效率，提供三種符合 iOS 現代化設計語言 (Modern SwiftUI) 的方案。

#### 方案 A：Minimalist Access (Apple Home 風格)

> **設計關鍵詞**：Clean, Typography, Whitespace

- **視覺特徵**：
  - 維持純白背景 (`Color.white`) 與標準陰影。
  - 將狀態濃縮為右上角的 **Status Pill** (膠囊標籤)。
  - **Normal**：灰色文字 + 綠色小圓點。
  - **Alert**：紅色背景膠囊 + 白色文字 + 警示圖標。
- **適用場景**：當儀表板資訊密度極高，需要降低視覺噪音時。

#### 方案 B：Dynamic Surface (Contextual 通知風格) **[推薦]**

> **設計關鍵詞**：Immersive, Color Semantics, Glanceability

- **視覺特徵**：
  - **容器染色**：背景色隨狀態改變，提供最強烈的視覺回饋。
  - **Normal**：`Color.white` (或極淡灰)，搭配標準綠色圖標。
  - **Alert**：`Color.red.opacity(0.1)` (淡紅背景)，文字轉為 `.red`，並疊加紅色邊框 (`.stroke`)。
  - **動畫**：狀態切換時使用 `.animation(.spring)` 進行背景色過渡。
- **優勢**：在「掃視」(Glance) 情境下能最快傳達異常，符合 Dashboard 核心目的。

#### 方案 C：Glassmorphism HUD (高科技風格)

> **設計關鍵詞**：Translucency, Mesh Gradient, Neumorphism

- **視覺特徵**：
  - **背景**：使用 `UltraThinMaterial` (磨砂玻璃)。
  - **光暈**：底部圖層放置 `AngularGradient` 或 Mesh Gradient，隨狀態旋轉或呼吸。
  - **Normal**：青色/藍色冷光呼吸。
  - **Alert**：橙紅色/紅色警示光脈衝 (Pulse)。
- **適用場景**：若 App 整體走向 Cyberpunk 或高科技工業風。

---

- **Swipe Cards (滑動分頁)**：
  - 使用 SwiftUI `TabView` 配合 `.tabViewStyle(.page(indexDisplayMode: .always))` 實現。
  - **卡片 1 (環境數據)**：整合顯示溫度與濕度。
    - **圖表模式 (預設)**：Swift Charts 雙線疊加圖表。溫度為橘色實線，濕度為藍色虛線。
    - **列表模式**：整合歷史列表。每行同時顯示 `時間 | 溫度 | 濕度`。
    - **切換機制**：右上角設有切換按鈕，點擊可於圖表與列表間切換。
    - **多裝置支援**：當數據來自多個 `device_id` 時，使用巢狀 TabView 滑動瀏覽各裝置數據。頂部顯示 Device Indicator 標示當前裝置。
  - **卡片 2 (裝置)**：顯示裝置狀態列表 (Online/Offline)。

### Footer (底部功能)

- 膠囊狀按鈕 (Capsule)，固定於底部，引導至「Warehouse Management」。

### 視覺風格

- **Digital Wabi-Sabi**：背景色 `Color("Stone50")`，圓角 `.cornerRadius(32)`，細微陰影 `.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)`。

---

## 實作參考

本視圖與 `DashboardViewModel` 深度互動，以下為關鍵代碼片段與後端數據整合指引。

### 1. 視圖實作 (DashboardView.swift)

```swift
// 即時數據卡片實作片段
private var bentoGrid: some View {
    HStack(spacing: 16) {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(Int(viewModel.currentReading?.temperature ?? 0))°")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.stone800)

                // 更新時間顯示 (Stage 2 規格: 24H)
                if let date = viewModel.currentReading?.createdAt {
                    Text(date, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.stone400)
                }
            }
            Text("AVG TEMP").font(.system(size: 10, weight: .medium)).foregroundColor(.stone400)
            Spacer()
            // ... 濕度顯示邏輯 ...
        }
        .padding(20).frame(height: 160).background(Color.white).cornerRadius(32)
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

## 架構與依賴 (Architecture & Dependencies)

- **Design Pattern**: MVVM + Observation (SwiftUI 17+)
- **View**: `DashboardView` (@[App/Views/DashboardView.swift])
- **ViewModel**: `DashboardViewModel` (@[App/ViewModels/DashboardViewModel.swift])
  - **Dependency**: `SupabaseManager` (Singleton) for Realtime Data.
- **Data Flow (Call Stack)**:
  1. `DashboardView` calls `viewModel.startListening()` on appear.
  2. `SupabaseManager` receives realtime payload.
  3. Payload decoded via `ReadingRow` internal struct.
  4. `DashboardViewModel` updates `@Observable var currentReading`.
  5. View reacts instantly.

## 注意事項

1. **ViewModel 生命週期**：請確保在 `onAppear` 呼叫 `startListening()`。
2. **數據流**：所有即時更新均由 `DashboardViewModel.currentReading` 驅動，UI 切勿持有重複狀態。
3. **解碼健壯性**：若 Realtime 斷開或解碼失敗，應在 `SupabaseManager` 捕獲 error 並嘗試重連。

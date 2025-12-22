# iOS 開發指引（Stage 2）

TeaWarehouse-MVP iOS 端已完成 Stage 1 基礎建設，並已進入 **Stage 2** 開發階段。目前已完成 `DashboardView` 的 UI/UX 重構。

## 歷史記錄

- Stage 1 完整內容已整合至：[`Doc/stage-1_ios.md`](stage-1_ios.md)
- **2025-12-23**: 審核 `DashboardView` 即時數據卡片，已補齊 `createdAt` 更新時間顯示。
- **2025-12-23**: 優化 `SupabaseManager` 的數據解碼邏輯（新增 ISO8601 日期策略與 `ReadingRow` 命名優化），確保即時數據能穩定驅動 UI。
- **2025-12-23**: 修正 `SupabaseManager` 編譯錯誤（移除 `execute(decoder:)` 調用，改為手動解碼），以適配 SDK 簽名。
- **2025-12-23**: 修復 `DashboardViewModel` 初始化邏輯，確保在歷史數據加載後立即更新 `currentReading`，解決首屏無數據顯示的問題。
- **2025-12-23**: 優化 `DashboardView` 即時數據的時間顯示，統一為 24 小時制 (`HH:mm`) 並移至卡片頂部，以反映溫濕度同步更新的特性。
- **2025-12-23**: 實作 `DashboardView` 異常警報卡片 (Exception Alert Card)。
  - `DashboardViewModel` 新增 `AlertType` 狀態邏輯 (Normal/Temperature/Humidity)。
  - UI 根據 `alertType` 動態切換樣式 (綠色/紅色) 與提示文字。
  - 修正 `checkAlert` 可見度問題，確保 Preview 能正確觸發警報狀態。
- **2025-12-23**: 更新協作協議，強制要求顯式依賴與架構模式標註 (Refined for .gemini)。
- **2025-12-23**: 提出 `DashboardView` 異常警報卡片的三種視覺設計方案 (Minimalist, Contextual, Glassmorphism) 供選型。
- **2025-12-23**: 確認採用 **方案 B (Dynamic Surface)**：Alert 狀態下使用淡紅背景 (`.red.opacity(0.1)`) + 紅色邊框，提升掃視辨識度。
- **2025-12-23**: 優化 **Exception Alert Card** 視覺佔比，解決 "Too much whitespace" 問題：
  - 放大 Main Title 至 `.title2` (Bold Rounded)。
  - 放大 Description 至 `.subheadline`。
  - 增加 Icon 尺寸並緊湊排列資訊。
- **2025-12-23**: 優化 `DashboardView` Swipe Cards (溫度/濕度分頁) 的列表顯示模式：
  - 數據源重構為 `(Date, Float)` Tuple，支援時間顯示。
  - 實作列表 **時間倒序 (Newest First)** 排列，確保最新數據置頂。
  - 圖表模式維持 **時間正序 (Oldest First)** 排列，確保繪圖正確。
- **2025-12-23**: 更新 `DashboardView` Preview 資料，改用具備時間間隔的 Mock Data，以提升圖表與歷史列表的視覺真實度。

## 依據

- PRD：[`../PRD_STAGE2.md`](../PRD_STAGE2.md) (若有)
- 設計規格：[`Doc/stage-2-view/STAGE_2_IOS_DashboardView.md`](Doc/stage-2-view/STAGE_2_IOS_DashboardView.md)
- 基礎：`Doc/stage-1_ios.md` 所列之架構與實作

## Stage 2 目標

1. **導航與多視圖**：完善 App 路由，處理更多業務場景。
2. **數據持久化與緩存**：優化本地數據存取，減少不必要的網路請求。
3. **UI 細化與互動**：基於已實作的 Bento Grid 與專屬動畫，持續優化視覺回饋。
4. **進階通知管理**：更靈活的通知設定（閾值自定義）。

## 原則 (Success Model: High-Probability)

本專案遵循 **High-Probability Success Model (Agentic PDCA)**，並執行嚴格的 **Context Injection** 以提升 Agent 實作成功率：

- **Context Integrity**: 文檔是專案的「長期記憶」，必須與代碼保持嚴格一致。
- **Token Economy**: 珍惜 Attention Window，代碼註釋專注於 "Why over What"。
- **Explicit Metadata (強制執行)**：
  - **Code Header**: 必須包含 `Architecture` (列出 Design Patterns, e.g., MVVM, Singleton) 與 `Dependencies` (列出關鍵依賴)。
  - **In-Code Annotation**: 在複雜邏輯處，需明確註明 `Data Structure` (如 `Set` 用於去重) 與 `Call Flow`。
  - **Doc Mapping**: 設計文件必須包含代碼連結 `@[File]` 與對應的關鍵函數 `Function Name`。
- **Doc Synchronization**: 任何修改後，必須同步更新 `AGENTS.md` 與 `README.md`。
- **Testing**: 持續編寫與維護測試案例，確保不回歸。

## 開發流程

1. 查閱 Stage 2 需求文件 (確認包含代碼映射指引)。
2. 更新相關 Model 與 ViewModel (需標註 Dependencies 與 Pattern)。
3. 實作新 View 並整合至導航流程。
4. 驗證新功能並進行回歸測試。

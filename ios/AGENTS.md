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
- **2025-12-23**: Optimize Dashboard Card Animation (Pinned Top, Expanded Down) @User
- **2025-12-23**: 修復 `DashboardView` 預覽數據失效問題：優化 `MockSupabaseManager` 使其具備持久化 Mock 資料的能力，解決 `.onAppear` 生命週期導致數據被空結果覆蓋的 Bug。
- **2025-12-23**: 進一步增強 Preview 穩定性：簡化 Mock 日期生成邏輯 (避免 Force Unwrap)、確保 `currentReading` 與歷史數據同步，並加強 `MockSupabaseManager` 的實現健壯性。
- **2025-12-23**: 優化 `DashboardView` Swipe Cards (滑動分頁)：移除歷史列表中的 "Reading + 數字" 標籤，僅保留時間與數據，以提升視覺清爽度。
- **2025-12-23**: 規劃並批准 **Unified Climate Card** 重構方案：將溫度與濕度整合為單一卡片，支援雙線圖表與整合歷史列表，並保留切換按鈕。
- **2025-12-23**: 實作**多裝置滑動瀏覽**：按 `device_id` 分組數據，支援巢狀 TabView 切換各裝置環境數據，頂部 Device Indicator 顯示當前裝置。
- **2025-12-23**: 整合**裝置狀態顯示**：將 `DeviceListCard` 的連線狀態與電量指示燈移植至 `UnifiedClimateCard` 標題，優化數據監控透明度。
- **2025-12-23**: **簡化導覽架構**：完成狀態功能整合後，正式移除 `DeviceListCard`，並將裝置位置 (Location) 整合至各氣候卡片標題，實現更直覺的單層滑動監控。
- **2025-12-23**: **同步設計文檔**：更新 `Doc/stage-2-view/STAGE_2_IOS_DashboardView.md` 以反映 `UnifiedClimateCard` 與「方案 B」警報卡片的最終實作，並補齊代碼函數映射。
- **2025-12-23**: **即時數據卡片優化**：調整 `DashboardView` 即時數據卡片的佈局，將溫濕度圖標移至數據左側並與時間圖標對齊，提升視覺層次的一致性。
  40: - **2025-12-23**: **重構異常警報卡片**：切換至 **方案 A (Minimalist Access)**。
  - 移除動態背景與邊框，復原純白 Bento 風格。
  - 新增右上角 **Status Pill** (膠囊標籤) 顯示即時狀態 (Normal/Alert)。
  - 優化內部排版與 `shield.fill` 圖標語義化顯示。
  - **Refactor**: 將警報卡片邏輯抽取為 `ExceptionAlertCard` 獨立組件，提升主視圖可讀性。
- **2025-12-23**: **Redesign Alert Card**: 採用 **Ambient Aura** 設計方案。
  - 引入動態漸層背景 (`LinearGradient`) 提供情緒化氛圍 (Blue/Mint vs Red/Orange)。
  - 優化圖標容器與層次感 (`Hierarchical Rendering`)。
  - 調整排版以適應更現代化的視覺風格。
- **2025-12-23**: **本地化與翻譯**：將 `DashboardView` 與 `DashboardViewModel` (警報文字) 翻譯為台灣中文，保留品牌名稱 "PU'ER SENSE" 為英文，提升在地化使用者體驗。
- **2025-12-23**: **Design System Upgrade**: 全面導入 **Neo-Bento** 設計系統 (Option 4)。
  - **Shared Design System**: 建立 `App/Design/DesignSystem.swift` 集中管理 Colors (Indigo/Yellow/Red) 與 Typography (Hero Number, Grid Header)。
  - **Dashboard Refactor**: 重構為 Hero Card (即時數據) + Status Card (3D Icon) + Context Card (Outline Style) 的模組化多欄網格。
  - **LoginView Redesign**: 移除茶餅插畫，轉為現代化的高張力排版 (Centered "PU'ER" Hero Text) 與高觸感輸入框 (Neo-Bento Input)。
- **2025-12-23**: **Google OAuth Integration**:
  - `SupabaseManager`: 新增 `signInWithOAuth` 與 `handle(url)` 支援深度連結回調。
  - `AuthViewModel`: 實作 `signInWithGoogle` 邏輯。
  - `LoginView`: 新增 "Continue with Google" 按鈕 (Neo-Bento Style)。
  - `TeaWarehouseApp`: 註冊 `.onOpenURL` 以處理 OAuth Callback。
- **2025-12-23**: **ProfileView 實作 (Identity Linking)**:
  - `SupabaseManager`: 新增 `linkIdentity`, `userIdentities`, `currentUserEmail` 支援身份連結。
  - `ProfileViewModel`: 管理用戶資料與 Identity 連結狀態。
  - `ProfileView`: Neo-Bento 風格的用戶個人頁面，顯示 Email、已連結帳號，及「連結 Google」按鈕。
  - `DashboardView`: 新增從 User Avatar 導航至 ProfileView 的功能。
- **2025-12-23**: **Refine ProfileView Color System**:
  - `ProfileView`: Replaced hardcoded colors with `DesignSystem` tokens (Danger/AccentA/TextSecondary) to ensure theme consistency.
  - Standardized "Link Google" button gradient and secondary text styling.
- **2025-12-23**: **Standardize Button Styling**:
  - `DesignSystem`: Promoted `ScaleButtonStyle` to shared Design System.
  - `ProfileView`: Updated "Link Google" button to match `LoginView` aesthetics (Card Surface + Outline + Shadow).
  - `LoginView`: Removed local `ScaleButtonStyle` to use shared definition.
- **2025-12-23**: **Refine ProfileView Colors**:
  - `ProfileView`: Changed Google icon color and "已連結" (Linked) status badge color from `Danger`/`AccentB` to `Primary` (Indigo), ensuring consistent use of the app's theme color.
- **2025-12-23**: **Sync User Avatar to Dashboard**:
  - `DashboardViewModel`: Added `fetchUserProfile` to retrieve user email.
  - `DashboardView`: Updated header avatar to match `ProfileView` style (Initial + Themed Gradient), creating a unified identity across views.
- **2025-12-23**: **新增可組合 Widget 組件 (B/C/D)**:
  - 新增 `App/Views/Widgets/` 資料夾，包含三個可組合的溫濕度 Widget：
  - `ComparisonPill.swift`: 雙指標膠囊，並排顯示溫度 (Indigo) 與濕度 (Green)，支援標準/緊湊模式。
  - `TrendSpark.swift`: 迷你走勢線 + 趨勢箭頭，使用 Swift Charts 繪製 Sparkline，自動計算趨勢 (Up/Down/Stable)。
  - `LiveTicker.swift`: 滾動數字動畫，iOS 17+ 使用 `contentTransition(.numericText())` 並提供 iOS 16 降級方案。
  - 所有組件嚴格遵循 `DesignSystem.swift` 配色規範。
- **2025-12-23**: **修復與實作 Widget Extension (Home Screen)**:
  - **Root Cause Fix**: 解決 `Failed to get descriptors` 錯誤。根本原因是 Widget 引用了主 App 的 `Color("Canvas")` 命名顏色，但該顏色不存在於 Widget 的 Asset Catalog 中，導致啟動時崩潰。
  - **Solution**: 將 `Color("Canvas")` 替換為 `Color(uiColor: .systemGroupedBackground)`，使用系統顏色避免 Asset Catalog 依賴。
  - **UI**: 實作 `com_puer_sense.swift`，支援 `systemSmall` / `systemMedium` 尺寸，整合 Indigo (溫度) 與 Green (濕度) 的品牌視覺。

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

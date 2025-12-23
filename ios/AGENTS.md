/\*

- File: ios/AGENTS.md
- Purpose: iOS Sub-project Runtime Status and AI Collaboration Protocol
- Architecture: MVVM, SwiftUI, Documentation-driven Development
- AI Context: Specific constraints for iOS development (Stage 2: Neo-Bento UI).
  \*/

# iOS 開發指引 (Stage 2)

本檔案紀錄 iOS 端模組的開發細節。請嚴格遵守 [GEMINI.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/GEMINI.md) 協議中的「高機率成功模型」。

## 🎯 當前進度 (Done)

- ✅ **Neo-Bento UI Implementation**: 完成 Dashboard 重構，導入 `Hero Card`、`Status Card` 與 `Context Card` 佈局。
- ✅ **Design System Layer**: 建立 `App/Design/DesignSystem.swift` 集中管理顏色、字體與組件樣式（如 `ComparisonPill`、`TrendSpark`）。
- ✅ **Auth & Identity**: 實作 Google OAuth 登入與身份連結 (`ProfileView`)。
- ✅ **Home Widget**: 動態溫濕度 Widget 開發完成，修復 `Asset Catalog` 依賴導致的崩潰問題。

## 📝 關鍵開發決策 (History)

- **2025-12-23 (UI/UX)**:
  - 核心介面轉向 **Neo-Bento Style**，移除贅餘插畫，強化排版張力。
  - 異常警報卡片採用 **Ambient Aura** 方案，結合 `LinearGradient` 提供直觀的環境回饋。
  - 整合 `UnifiedClimateCard`，按 `device_id` 滑動瀏覽數據，並整合裝置狀態指示燈。
- **2025-12-23 (Infrastructure)**:
  - 優化 `SupabaseManager` 的日期處理策略，支援微秒級與 ISO8601 格式相容。
  - 建立具備數據持久化能力的 `MockSupabaseManager` 以提升系統預覽 (Preview) 穩定性。
  - 實作可重用的 Widget 組件庫 (`ComparisonPill`, `TrendSpark`, `LiveTicker`)。

## 🚧 下一步 (Next Steps)

- [ ] **Data Persistence & Cache**: 實作本地數據緩存，優化離線瀏覽體驗。
- [ ] **Dynamic Thresholds**: 實作自定義警報閾值設定介面。
- [ ] **Navigation Refactoring**: 完善多層次路由管理，支援從通知直接跳轉至特定裝置。

---

## 🛠️ 開發守則 (Success Model)

1. **Context Integrity**: 代碼 Header 必須包含 `Architecture` 與 `Dependencies`。
2. **Architecture Focus**: 嚴格遵守 **MVVM** 模式，避免 View 內夾雜邏輯。
3. **Explicit Metadata**: 複雜邏輯需標註 `Data Structure` 與 `Call Flow`。
4. **Link Mapping**: 開發前查閱設計規格書：[STAGE_2_IOS_DashboardView.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/Doc/stage-2-view/STAGE_2_IOS_DashboardView.md)

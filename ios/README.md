# iOS (SwiftUI)

本目錄為 Pu'er Sense 的 iOS 端開發主場。採用 SwiftUI + MVVM 架構，並已進入 **Stage 2 (Neo-Bento UI Refactor)**。

## 📍 AI 導航索引 (Path Index)

為協助 AI Agent 快速理解架構，核心模組定位如下：

- **App 入口**: [`App/TeaWarehouseApp.swift`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/TeaWarehouseApp.swift)
- **設計系統**: [`App/Design/DesignSystem.swift`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/Design/DesignSystem.swift) - 管理 Colors, Typography & Shapes.
- **視圖層 (Views)**:
  - [`App/Views/DashboardView.swift`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/Views/DashboardView.swift) - 主儀表板 (Bento Layout).
  - [`App/Views/Widgets/`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/Views/Widgets/) - 可重用的 Widget 組件庫.
- **邏輯層 (ViewModels)**:
  - [`App/ViewModels/DashboardViewModel.swift`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/ViewModels/DashboardViewModel.swift)
- **管理層 (Managers)**:
  - [`App/Services/SupabaseManager.swift`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/Services/SupabaseManager.swift)

## 📄 相關文件

- **當前重點**: [`AGENTS.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/AGENTS.md) - Stage 2 指引、目標與開發紀錄。
- **設計規格**: [`Doc/stage-2-view/STAGE_2_IOS_DashboardView.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/Doc/stage-2-view/STAGE_2_IOS_DashboardView.md)
- **歷史備份**: [`Doc/stage-1_ios.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/Doc/stage-1_ios.md)

## 🚀 Stage 2 主要目標

1. **Neo-Bento UI**: 完善儀表板多欄位網格與 Hero Card 視覺震撼力。
2. **Identity Linking**: 完善 Google OAuth 與多重身份連結邏輯。
3. **Data Polish**: 實作 Sparkline 走勢圖與雙指標 Comparison Pill。
4. **Resilience**: 優化 `MockSupabaseManager` 的持久化預覽能力。

---

> [!IMPORTANT]
> **維護要求**：任何代碼或架構異動後，必須同步更新 `AGENTS.md`。README 則專注於長期穩定的架構索引。

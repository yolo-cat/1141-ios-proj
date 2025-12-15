# iOS (SwiftUI)

TeaWarehouse-MVP 的 iOS 端以 SwiftUI + MVVM 開發，串接 Supabase Realtime 與 History 圖表。請先閱讀：
- `PRD_IOS_STAGE_1.md`：Stage 1 需求摘錄（完整需求見 `../PRD_STAGE1.md`）
- `AGENTS.md`：Stage-1 專屬開發指引
- `DESIGN_IOS_STAGE_1.md`：設計概要
- `TASKS_IOS_STAGE_1.md`：依指引拆解的落地步驟
- `TEST_IOS_STAGE1.md`：Stage 1 測試計畫、TDD 流程與完成度檢查；XCTest 骨架位於 `test/stage_1/`

## 代碼骨架 (Stage 1)
- App 入口與 SwiftUI 結構：`App/TeaWarehouseApp.swift`、`App/Views/RootView.swift`
- 模組化目錄：`App/Models/`、`App/Managers/`、`App/ViewModels/`、`App/Views/`
- Supabase 介接：`App/Managers/SupabaseManager.swift`（stub，可替換為 supabase-swift）
- MVVM：`AuthViewModel`、`SensorViewModel`，對應 `LoginView`、`DashboardView`、`HistoryChartView`

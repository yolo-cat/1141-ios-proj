# iOS (SwiftUI)

TeaWarehouse-MVP 的 iOS 端以 SwiftUI + MVVM 開發，串接 Supabase Realtime 與 History 圖表。請先閱讀：
- `PRD_IOS_STAGE_1.md`：Stage 1 需求摘錄（完整需求見 `../PRD_STAGE1.md`）
- `AGENTS.md`：Stage-1 專屬開發指引
- `DESIGN_IOS_STAGE_1.md`：設計概要
- `TASKS_IOS_STAGE_1.md`：依指引拆解的落地步驟

## Stage-1 狀態檢查（本次開發）
- [ ] AuthViewModel / Session 維持（程式碼待補）
- [ ] SupabaseManager 與 Realtime/查詢串接
- [ ] Login/Dashboard/History SwiftUI 畫面與門檻提醒
- [x] 測試計畫：`TEST_IOS_STAGE1.md`
- [x] 測試樣板程式碼：`test/stage_1/Stage1SpecTests.swift`（XCTest 規格替身）

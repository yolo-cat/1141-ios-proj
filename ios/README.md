# iOS (SwiftUI)

TeaWarehouse-MVP 的 iOS 端以 SwiftUI + MVVM 開發，串接 Supabase Realtime。專案已進入 **Stage 2**：功能擴展與細化。

## 相關文件

- `AGENTS.md`：Stage 2 開發指引與目標 (**當前開發重點**)
- `Doc/stage-2-view/STAGE_2_IOS_DashboardView.md`：Stage 2 儀表板設計規格
- `Doc/stage-1_ios.md`：Stage 1 需求、設計與測試完整記錄（歷史資料）

## 代碼骨架 (Stage 2)

- **App 入口**：`App/TeaWarehouseApp.swift`
- **主要視圖**：
  - `DashboardView.swift`：採用 Bento Grid 佈局，整合即時數據、警示與滑動式分析卡片。
  - `LoginView.swift`：認證界面。
- **架構**：MVVM (Model-View-ViewModel) + Observation 框架。
- **測試**：`test/` 目錄，包含單元測試與整合測試

## Stage 2 主要目標

1. 完善導航與多視圖路由
2. 實施本地數據持久化與緩存
3. 優化 UI 動態效果與自定義視圖
4. 增強通知系統與閾值管理

---

> [!IMPORTANT]
> **維護要求**：當有任何代碼修改時，必須自動且同步地更新 `README.md` 與 `AGENTS.md` 中的對應內容，以確保文檔與代碼高度一致。

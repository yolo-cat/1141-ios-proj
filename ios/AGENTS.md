# iOS 開發指引（Stage 2）

TeaWarehouse-MVP iOS 端已完成 Stage 1 基礎建設，並已進入 **Stage 2** 開發階段。目前已完成 `DashboardView` 的 UI/UX 重構。

## 歷史記錄

- Stage 1 完整內容已整合至：[`Doc/stage-1_ios.md`](stage-1_ios.md)

## 依據

- PRD：[`../PRD_STAGE2.md`](../PRD_STAGE2.md) (若有)
- 設計規格：[`Doc/stage-2-view/STAGE_2_IOS_DashboardView.md`](Doc/stage-2-view/STAGE_2_IOS_DashboardView.md) (Bento Grid, Swipe Cards)
- 基礎：`Doc/stage-1_ios.md` 所列之架構與實作

## Stage 2 目標

1. **導航與多視圖**：完善 App 路由，處理更多業務場景。
2. **數據持久化與緩存**：優化本地數據存取，減少不必要的網路請求。
3. **UI 細化與互動**：基於已實作的 Bento Grid 與專屬動畫，持續優化視覺回饋。
4. **進階通知管理**：更靈活的通知設定（閾值自定義）。

## 原則 (Success Model)

本專案遵循 **High-Probability Success Model (Agentic PDCA)**：

- **Context Integrity**: 文檔是「長期記憶」，必須與代碼嚴格一致。
- **Token Economy**: 珍惜 Attention Window，代碼註釋專注於 "Why over What"。
- **Header Standard**: 所有檔案必須具備 `AI-Optimized Header`。
- **Doc Synchronization**: 任何修改後，必須同步更新 `AGENTS.md` 與 `README.md`。
- **Testing**: 持續編寫與維護測試案例，確保不回歸。

## 開發流程

1. 查閱 Stage 2 需求文件。
2. 更新相關 Model 與 ViewModel。
3. 實作新 View 並整合至導航流程。
4. 驗證新功能並進行回歸測試。

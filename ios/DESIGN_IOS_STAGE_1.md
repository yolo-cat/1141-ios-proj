# DESIGN_IOS_STAGE_1

設計概要（依 `PRD_IOS_STAGE_1.md`）：

1. 架構：SwiftUI + MVVM。`SupabaseManager` 單例提供 auth、realtime、查詢。
2. Model：`Reading` 對應 Supabase `readings` 欄位，使用 `Float` 表示溫/濕度。
3. ViewModels：
   - `AuthViewModel`：登入/註冊並維護 session。
   - `SensorViewModel`：訂閱 `readings` `INSERT` 更新 `currentReading`，並抓取歷史資料供圖表。
4. Views：
   - `LoginView` 驗證。
   - `DashboardView` 顯示最新數據並在超標時觸發震動/通知。
   - `HistoryChartView` 使用 Swift Charts 呈現歷史雙折線。

執行步驟與細節請參考 [`TASKS_IOS_STAGE_1.md`](TASKS_IOS_STAGE_1.md) 與 `AGENTS.md`。

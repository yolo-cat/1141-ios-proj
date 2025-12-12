# iOS Stage-1 落地步驟

本指引依據 `ios/AGENTS.md` 與 `stage_1_prd.md`，將工作拆解為可立即執行的動作。

1. **初始化專案**
   - 建立 SwiftUI App 專案（iOS 17+，Swift 5.9+），建立資料夾 `Models/`, `ViewModels/`, `Views/`, `Managers/`.
2. **加入依賴**
   - 以 Swift Package Manager 新增 `supabase-swift`、`Swift Charts`；確認可在 Xcode 編譯。
3. **設定 Supabase**
   - 建立 `SupabaseManager` 單例：持有 client（url/key 由環境或 Build Settings 注入），提供 auth、realtime、查詢入口。
4. **定義模型**
   - 建立 `Reading`（對應 `readings` 欄位 `id`, `created_at`, `device_id`, `temperature: Float`, `humidity: Float`）。
5. **實作 Auth**
   - `AuthViewModel`：登入/註冊（email+password）、維護 session、登入成功後流向主畫面。
6. **即時資料**
   - `SensorViewModel`：訂閱 `readings` 的 `INSERT` Realtime 更新 `currentReading`；提供拉取最近 100 筆 (或 24 小時) 的查詢方法。
7. **介面**
   - `LoginView`、`DashboardView`（顯示最新溫/濕度卡片，超標 Temp>30 或 Humidity>70 觸發震動/通知）、`HistoryChartView`（Swift Charts 雙折線）。
8. **驗證**
   - 用測試帳號登入，觀察 Realtime 更新與圖表渲染；模擬超標數值確認震動/通知行為。

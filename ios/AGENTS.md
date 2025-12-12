# iOS 開發指引（Stage 1）

TeaWarehouse-MVP iOS 端採用 SwiftUI + MVVM，資料源來自 Supabase。閱讀此檔前，請先掌握根目錄的 `AGENTS.md` 與 `PRD_STAGE1.md`（摘要於 `PRD_IOS_STAGE_1.md`）。

## 依據
- PRD：[`../PRD_STAGE1.md`](../PRD_STAGE1.md)（資料表 `readings`、Auth、Realtime、History 圖表）
- Prompt 範本：[`../stage_1_prompt.md`](../stage_1_prompt.md) 的 iOS 指令區段

## 原則
- **框架**：iOS 17+、Swift 5.9+、SwiftUI、`supabase-swift`、`Swift Charts`
- **架構**：MVVM，ViewModel 不直接持有 View
- **資料**：`readings` 欄位 `id | created_at | device_id | temperature | humidity`（PostgreSQL: float4；Swift: Float）
- **即時性**：Dashboard 需訂閱 Realtime `INSERT`，History 以查詢排序後繪圖
- **安全**：Anon 只用於寫入設備；App 讀取需 authenticated session

## Stage-1 必備輸出
1) Auth：Email/Password 登入與註冊，保存 Session  
2) Supabase 客戶端單例（供 ViewModel 共用）  
3) Model `Reading` 對應資料表  
4) `SensorViewModel`：訂閱 `readings` `INSERT`、維護 `currentReading`、抓取歷史資料（預設 24h × 12 次/小時 ≈ 288 筆，Demo 可 100 筆）供圖表  
5) 視圖：Dashboard（即時卡片 + 超標震動/通知）、History（Swift Charts 折線）  

## 最小開發流程（概要）
1. 建立 SwiftUI App 專案骨架與資料夾：Models / ViewModels / Views / Managers  
2. 加入 `supabase-swift`、`Swift Charts`，配置 Supabase URL/keys（以環境檔或 Build Setting 注入）  
3. 實作 Model + SupabaseManager  
4. 實作 ViewModel（Auth / Sensor），串接 Realtime + 查詢  
5. 建立 LoginView、DashboardView、HistoryChartView，串接 ViewModel  
6. 驗證：登入 -> 觀察 Realtime 更新與圖表渲染；超標時觸發 haptic/通知  

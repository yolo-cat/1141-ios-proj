# TEST_IOS_STAGE1

TeaWarehouse-MVP iOS（Stage 1）測試方案，涵蓋 PRD 需求：Auth、Dashboard Realtime、History 圖表。程式級測試骨架存放於 `ios/test/stage_1/`，以 XCTest 為主（可於 Xcode test target 啟用）。

## 範圍與環境
- 平台：iOS 17+、SwiftUI、Swift 5.9+、`supabase-swift`、`Swift Charts`
- 資料：`readings` 欄位 `id | created_at | device_id | temperature(Float) | humidity(Float)`（Supabase `float4`）
- 目標：驗證登入/註冊流程、Realtime `INSERT` 訂閱、歷史查詢與圖表資料、超標通知/震動
- 前置：Supabase URL/anon/service key 注入，測試帳號存在或可動態註冊；可使用 stub/mocks 取代真實連線

## 測試類型
1) **單元測試**
   - SupabaseManager：初始化與 session 保存
   - AuthViewModel：`signIn`/`signUp` 流程、錯誤回報、session 缓存/清除
   - SensorViewModel：Realtime 訂閱 callback 更新 `currentReading`，歷史查詢封裝（筆數上限/排序）
2) **整合測試**
   - 以 mock Supabase client 驗證 Realtime 訂閱收到 `INSERT` 後 UI 狀態更新
   - 歷史查詢結果可轉為 Chart 所需的雙折線資料序列
3) **UI/手動回歸**
   - LoginView：登入/註冊流程與錯誤訊息
   - DashboardView：最新讀數卡片即時跳動，溫度>30 或濕度>70 時觸發 haptic/本地通知
   - HistoryChartView：折線顯示最近 N 筆數據，空資料時呈現 placeholder

## 主要測試案例（摘要）
- AUTH-001：給定有效 email/password，呼叫 signIn 後得到 session 並觸發 onAuthChanged。
- AUTH-002：signUp 失敗時回傳錯誤並維持未登入狀態。
- REALTIME-001：模擬 `readings` `INSERT` payload，SensorViewModel 更新 `currentReading.device_id/temperature/humidity/created_at`。
- REALTIME-002：關閉訂閱後再發出 payload，`currentReading` 不再變更。
- HISTORY-001：查詢限制 100/288 筆並依 `created_at` 由舊到新排序。
- HISTORY-002：將查詢結果轉成 Swift Charts 雙折線資料點（Temp/Humidity）。
- ALERT-001：當最新讀數超過閾值 (Temp>30 or Humidity>70) 時，觸發 haptic/通知，並記錄最後觸發時間避免過度提醒。

## TDD 範例流程（建議順序）
1. 單元：AuthViewModel sign-in/signup happy path 與錯誤
2. 單元：SensorViewModel 歷史查詢封裝（上限、排序）
3. 單元：SensorViewModel Realtime callback 更新 state
4. 整合：Dashboard 觀察 Realtime，History 資料轉折線
5. UI：登入到 Dashboard 的跳轉、超標提示

## 完成度檢查 (Stage 1)
- [ ] Auth：email/password 登入/註冊、Session 保存
- [ ] Realtime：訂閱 `readings` `INSERT` 並更新最新讀數
- [ ] History：查詢排序後的最近 N 筆資料餵給 Swift Charts
- [ ] Alert：超標震動/通知與節流
- [ ] 文件：測試計畫、TDD 流程、執行指引已更新

# TEST_IOS_STAGE1

依 `PRD_IOS_STAGE_1.md` 與 `TASKS_IOS_STAGE_1.md` 撰寫的 Stage-1 測試計畫，聚焦於 Auth、Realtime、History 圖表與超標提醒。

## 範圍與環境
- 裝置：iOS 17+ 實機或模擬器。
- 架構：SwiftUI + MVVM，使用 `supabase-swift`、`Swift Charts`。
- 後端：Supabase `readings` 表（欄位：id, created_at, device_id, temperature: float4, humidity: float4）。
- 組態：在 Xcode Build Setting/環境檔注入 `SUPABASE_URL`、`SUPABASE_ANON_KEY`，測試帳號使用 email/password。

## 前置條件
- Supabase 專案已建立 `readings` 表與 RLS（anon 可寫入，authenticated 可讀取）。
- App 能登入測試帳號並初始化 `SupabaseManager`。
- 如需觸發 Realtime，可用 REST/SQL 手動插入測試行：
  - `device_id`：`tea_room_01`
  - `temperature`/`humidity`：自訂數值以模擬超標或正常情境。

## 驗證項目與步驟
### 1) Auth 流程
- **註冊/登入**：使用測試 email/password 完成註冊，再嘗試登入；預期拿到 session 並導向 Dashboard。
- **Session 維持**：重啟 App 後自動載入既有 session；若 token 過期應要求重新登入。
- **登出**：執行登出後，Realtime 訂閱與歷史查詢應停止，回到登入畫面。

### 2) Realtime 最新值
- 啟動 Dashboard 後插入一筆 readings（溫/濕度任意）。
- **期望**：`SensorViewModel.currentReading` 即時更新；UI 卡片顯示新值且時間戳與插入值相符。
- **斷線重試**：暫時關閉網路再恢復，訂閱應自動重連並接續接收後續 INSERT。

### 3) 超標提醒（Temp>30 或 Humidity>70）
- 插入 `temperature=31` 或 `humidity=75` 的讀數。
- **期望**：Dashboard 觸發震動/通知旗標，UI 顯示提醒狀態；若使用可設定閾值，覆寫後應依新閾值判定。

### 4) 歷史查詢與圖表
- 以 ViewModel 呼叫歷史 API（預設上限 100 或 288 筆）。
- **排序**：回傳資料依 `created_at` 降冪。
- **上限**：當資料多於上限時自動截斷。
- **圖表**：Swift Charts 雙折線載入相同筆數；空資料時顯示 placeholder 而非閃退。

### 5) 錯誤處理與 UX
- 網路不可用時顯示離線提示；恢復網路時自動重新訂閱並重試歷史拉取。
- Supabase 回傳 401/403 時，導向重新登入並清除 session。
- NaN 或不合法資料應忽略且提示（避免繪圖例外）。

## 驗證紀錄（示例）
- [ ] Auth：註冊/登入/登出流程
- [ ] Realtime：INSERT 即時更新
- [ ] 超標提醒：Temp>30 / Humidity>70 觸發
- [ ] 歷史：排序、上限、空資料處理
- [ ] 錯誤處理：離線、401/403、NaN

## 參考
- `ios/test/stage_1/`：對應的 XCTest 規格與替身，用於 TDD 與行為驗證範例。

# PRD_IOS_STAGE_1

此文件摘錄 Stage 1 的 iOS 需求，完整內容請見 [`../PRD_STAGE1.md`](../PRD_STAGE1.md)。

- 平台：iOS 17+，SwiftUI + MVVM，使用 `supabase-swift`、`Swift Charts`。
- 功能：
  - Auth：Email/Password 登入與註冊，保存 Session。
  - Dashboard：訂閱 `readings` Realtime `INSERT`，即時顯示最新溫/濕度，超標（Temp>30 或 Humidity>70）觸發震動/通知。
  - History：查詢排序後的歷史讀數（預設 288 筆或 Demo 100 筆），以雙折線圖呈現。
- 資料模型：`id | created_at | device_id | temperature (Float) | humidity (Float)` 對應 Supabase `float4` 欄位。

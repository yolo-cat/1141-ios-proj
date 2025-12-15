# DESIGN_STAGE1

此文件提供 Stage 1 的高層設計索引，細節集中於各子專案的設計文件：

- Backend：[`supabase/DESIGN_SUPABASE_STAGE_1.md`](supabase/DESIGN_SUPABASE_STAGE_1.md)
- Firmware：[`esp32/DESIGN_ESP32_STAGE_1.md`](esp32/DESIGN_ESP32_STAGE_1.md)
- iOS：[`ios/DESIGN_IOS_STAGE_1.md`](ios/DESIGN_IOS_STAGE_1.md)

整體流程概述：

1. ESP32（GPIO 32 讀取 DHT11）定期量測並透過 REST 將 JSON 上傳到 Supabase `readings` 表。
2. Supabase 儲存並以 RLS 控制權限：anon 可寫入、authenticated 可讀取。
3. iOS App 使用 `supabase-swift` 訂閱 Realtime INSERT 取得最新讀數，並查詢歷史資料以 Swift Charts 呈現。

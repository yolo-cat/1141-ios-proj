# PRD_ESP32_STAGE_1

此文件摘錄 Stage 1 的 ESP32 需求，完整描述請見 [`../PRD_STAGE1.md`](../PRD_STAGE1.md)。

- 硬體：ESP32-WROOM-32E + DHT11（GPIO 15）。
- 週期：預設每 5 分鐘讀取，Demo 模式 10 秒；若為 NaN 則跳過。
- 傳輸：以 REST POST 至 `<SUPABASE_URL>/rest/v1/readings`，JSON 欄位 `device_id | temperature | humidity`。
- 權限：Header 含 `apikey` 與 `Authorization: Bearer <anon key>`；不提交實際憑證，使用 `secrets.h` 或等效方式注入。

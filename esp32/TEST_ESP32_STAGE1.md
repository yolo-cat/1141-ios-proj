# TEST_ESP32_STAGE1

Stage 1 測試方案，聚焦 DHT11 (GPIO 15) 讀值並以 REST POST 上傳到 Supabase `readings` 表。對應需求請參考 `PRD_ESP32_STAGE_1.md` 與 `TASKS_ESP32_STAGE_1.md`。

## 目標與範圍
- 驗證核心行為：Wi-Fi 連線/自動重連、NaN 跳過、正確 JSON Payload 與 HTTP Header、標準/ Demo 週期（5 分鐘 / 10 秒）。
- 驗證資料上傳：`device_id | temperature | humidity` 送至 `<SUPABASE_URL>/rest/v1/readings`，Header 含 `apikey` 與 `Authorization: Bearer <anon>`, `Content-Type: application/json`, `Prefer: return=minimal`。
- 驗證安全性：機密值由未版控的 `secrets.h` 讀取，程式碼不含實際憑證。

## 測試環境
- 硬體：ESP32-WROOM-32E + DHT11（資料腳位接 GPIO 15）。
- 韌體：Stage 1 草稿/主程式（依 `arduino_draft.ino` 或後續正式檔），以及 `esp32/test/stage_1/` 內的測試腳本（Unity 形式，可用 PlatformIO `pio test` 執行）。
- 設定：`secrets.h` 內提供 `WIFI_SSID`、`WIFI_PASSWORD`、`SUPABASE_URL`、`SUPABASE_ANON_KEY`。連線到可用 Wi-Fi；Supabase 需已有 `readings` 表與 RLS（anon insert / authenticated select）。
- 工具：Serial Monitor（115200）、Supabase SQL/Console 觀察 `readings` 表。

## 測試項目與預期
- **連線/重連**：上電後應連上指定 SSID，斷線時自動重連並於序列埠紀錄。
- **讀值**：取得溫溼度；若任一為 NaN 則跳過上傳並記錄。
- **Payload / Header**：序列埠輸出或測試腳本檢查 JSON 內含 `device_id/temperature/humidity`，Header 正確帶入 `apikey`、`Authorization Bearer`、`Content-Type`、`Prefer`。
- **頻率**：標準模式約 300000ms 間隔；Demo 模式約 10000ms。
- **資料落庫**：Supabase `readings` 新增行數與裝置時間相符；HTTP 狀態碼 201/204。

## 手動測試步驟（示例）
1. 燒錄 Demo 模式韌體；開啟 Serial Monitor。
2. 確認開機連線訊息，拔掉 Wi-Fi/關閉 AP 以觸發重連，再恢復連線。
3. 觀察每 10 秒讀值；刻意遮蔽感測器或拔除資料線以觸發 NaN，確認跳過上傳。
4. 重新連好感測器後觀察正常上傳；記錄一筆 HTTP 成功訊息。
5. 到 Supabase `readings` 查詢最新幾筆資料，確認欄位值與序列埠輸出一致。

## 自動化測試（Unity 腳本）
- 位置：`esp32/test/stage_1/test_stage1.cpp`。
- 內容：檢查 Payload 結構、NaN 濾除、標準/ Demo 週期毫秒值與上傳前條件（需 Wi-Fi & 有效讀值）。可於 PlatformIO 執行 `pio test -e native` 或放置於 Arduino `test` 目錄執行。
- 覆蓋範圍：不依賴實體 DHT11/HTTP，聚焦純邏輯（TDD 入口）；硬體/雲端行為仍需手動驗證。

## 完成度檢查（本次開發）
- [x] 測試方案文件（本檔）。
- [x] Stage 1 TDD 測試腳本 scaffold：`esp32/test/stage_1/`。
- [ ] 韌體調整至 Stage 1 要求（目前 `arduino_draft.ino` 為舊版 Blynk 草稿，尚需依 PRD 更新）。
- [ ] 實機驗證（需可用 Wi-Fi 與 Supabase 專案）。

## 參考
- 需求：`PRD_ESP32_STAGE_1.md`
- 設計：`DESIGN_ESP32_STAGE_1.md`
- 任務：`TASKS_ESP32_STAGE_1.md`
- 機密範本：`secrets.h.template`

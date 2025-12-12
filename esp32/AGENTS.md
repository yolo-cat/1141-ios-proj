# ESP32 Agent 指南（Stage 1）

本指引協助 AI Agent 以最小改動完成 ESP32 韌體的 stage-1 開發，需與根目錄 `AGENTS.md` 與 `PRD_STAGE1.md` 保持一致（摘要見 `PRD_ESP32_STAGE_1.md`），任一文件更新時請同步檢查本檔與 `TASKS_ESP32_STAGE_1.md`。

## 任務目標
- 以 ESP32 + DHT11（GPIO 15）讀取溫溼度，並透過 Supabase REST API 上傳。
- 標準週期每 5 分鐘讀取；Demo 模式 10 秒。若讀取為 NaN 則跳過上傳。
- 送出 JSON：`{"device_id":<string>,"temperature":<float>,"humidity":<float>}`，`device_id` 以可設定常數（範例值 `tea_room_01`）提供；HTTP Header 包含 `apikey` 與 `Authorization: Bearer <anon key>`。

## 開發守則
- 連網：開機連指定 Wi-Fi，偵測斷線需自動重連並寫入日誌。
- 感測：使用 `DHTesp` 或等效函式庫，初始化於 `setup()`，錯誤時提供清楚的序列埠輸出。
- 傳輸：使用 `HTTPClient` + `ArduinoJson`，設定 `Content-Type: application/json` 與 `Prefer: return=minimal`。
- 安全：不要提交實際的 Wi-Fi / Supabase 金鑰；以占位符或 `secrets.h` (未版本控制) 注入。

## 交付物
- 單一草稿/主要 Sketch（`arduino_draft.ino` 或後續正式檔），可切換標準/ Demo 週期。
- 簡短測試說明：如何於序列埠檢視連線、NaN 跳過、POST 成功回應狀態。
- 若需要額外檔案，保持命名簡潔並在 README 標註入口。

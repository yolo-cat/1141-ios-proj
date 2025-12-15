# DESIGN_ESP32_STAGE_1

設計概要（依 `PRD_ESP32_STAGE_1.md`）：

1. 啟動時初始化 Wi-Fi，自動偵測斷線並重連。
2. `setup()` 初始化 DHT11（GPIO 32）；`loop()` 依模式（5 分鐘/10 秒）讀值，NaN 則記錄並跳過上傳。
3. 使用 `HTTPClient` + `ArduinoJson` POST 至 Supabase REST，標頭含 `apikey`、`Authorization: Bearer <anon>`，`Content-Type: application/json`、`Prefer: return=minimal`。
4. 機密由 `secrets.h`（未版控）提供，避免硬編碼。

落地步驟請參考 [`TASKS_ESP32_STAGE_1.md`](TASKS_ESP32_STAGE_1.md) 與範例草稿 `arduino_draft.ino`。

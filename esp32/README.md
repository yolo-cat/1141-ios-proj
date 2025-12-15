# ESP32 (Arduino)

Stage-1 firmware workspace for sending DHT11 readings to Supabase.

- 需求：`PRD_ESP32_STAGE_1.md`（完整需求見 `../PRD_STAGE1.md`）。
- 設計與守則：`AGENTS.md`、`DESIGN_ESP32_STAGE_1.md`。
- 可執行步驟：`TASKS_ESP32_STAGE_1.md`（GPIO 15、5 分鐘周期，Demo 10 秒）。
- Stage 1 韌體：`arduino_draft.ino`（預設 5 分鐘讀值，`DEMO_MODE=true` 時 10 秒）。
- 機密範本：`secrets.h.template`（自建 `secrets.h` 並加入 `.gitignore`）。

## 快速測試
1. 將 `secrets.h.template` 複製為 `secrets.h`，填入 Wi-Fi、Supabase URL/anon key、`DEVICE_ID`；若無根憑證可暫時將 `ALLOW_INSECURE_TLS` 設為 `true`（需 DEBUG 組態，僅供測試）。
2. 依需求調整 `DEMO_MODE`（預設 `false` 為 5 分鐘；Demo 10 秒），燒錄 `arduino_draft.ino` 至 ESP32。
3. 以序列埠監看：可見 Wi-Fi 連線/重連、NaN 讀值跳過、以及 POST 回應的 HTTP 狀態碼。Supabase `readings` 表應新增對應行。

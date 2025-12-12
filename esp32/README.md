# ESP32 (Arduino)

Stage-1 firmware workspace for sending DHT11 readings to Supabase.

- 需求：`PRD_ESP32_STAGE_1.md`（完整需求見 `../PRD_STAGE1.md`）。
- 設計與守則：`AGENTS.md`、`DESIGN_ESP32_STAGE_1.md`。
- 可執行步驟：`TASKS_ESP32_STAGE_1.md`（GPIO 15、5 分鐘周期，Demo 10 秒）。
- 草稿範例：`arduino_draft.ino`（DHT11→Supabase REST；含 payload 自我檢查與 Wi-Fi 自動重連）。
- 機密範本：`secrets.h.template`（自建 `secrets.h` 並加入 `.gitignore`）。

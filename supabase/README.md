/\*

- File: supabase/README.md
- Purpose: Supabase Backend Project Overview and Development Guide
- Architecture: Supabase (PostgreSQL, RLS, REST API)
- AI Context: Source of truth for database schema and integration endpoints.
  \*/

# Supabase 後端概觀

本目錄包含 Pu'er Sense 專案的 Supabase 後端實作。目前已進入 **Stage 2 (Planning)**。

## 🚀 核心索引 (Index)

- **當前日誌**: [`AGENTS.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/supabase/AGENTS.md)
- **實作詳情**: [`STAGE_1.md`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/supabase/STAGE_1.md) - Stage 1 備份。
- **SQL 遷移**: [`001_create_readings_table.sql`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/supabase/001_create_readings_table.sql)

## 🏗️ 模組狀態 (Status)

### ✅ Stage 1 (Done)

- **readings 資料表**: 存儲設備數據 (`device_id`, `temperature`, `humidity`).
- **RLS 策略**: 已配置 `anon` 寫入與 `authenticated` 讀取權限。
- **測試工具**: `test_supabase_stage1.sh` 端到端驗證腳本。

### 🚧 Stage 2 (Planning)

- **聚合查詢**: 規劃 Hourly/Daily 統計 API。
- **Edge Functions**: 用於異常數據推送通知與警報邏輯。
- **數據完整性**: 強化批次寫入的驗證邏輯。

---

> [!IMPORTANT]
> **維護要求**：Schema 或 RLS 的任何變動必須同步更新至 `AGENTS.md` 並維持遷移檔案的冪等性。

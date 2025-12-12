# DESIGN_SUPABASE_STAGE_1

設計重點（依 [`PRD_SUPABASE_STAGE_1.md`](PRD_SUPABASE_STAGE_1.md)）：

1. Schema 與 RLS 以可重複執行的 SQL 定義，集中在 `supabase/` 目錄。
2. 權限切分：`anon` 只用於 INSERT；App 使用 authenticated token 讀取。
3. 驗證路徑：使用 REST POST/GET 驗證策略（指令示例見 `README.md`）。

執行步驟與 SQL 請參考 [`TASKS_SUPABASE_STAGE_1.md`](TASKS_SUPABASE_STAGE_1.md)。

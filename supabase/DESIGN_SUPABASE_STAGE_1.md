# DESIGN_SUPABASE_STAGE_1

**狀態：✅ 已完成實作**

設計重點（依 [`PRD_SUPABASE_STAGE_1.md`](PRD_SUPABASE_STAGE_1.md)）：

1. ✅ Schema 與 RLS 以可重複執行的 SQL 定義，集中在 `supabase/` 目錄。
   - 實作檔案：`001_create_readings_table.sql`
   - 支持冪等性（idempotent），可安全重複執行

2. ✅ 權限切分：`anon` 只用於 INSERT；App 使用 authenticated token 讀取。
   - RLS Policy 1: `allow anon insert` - 允許匿名用戶插入（ESP32）
   - RLS Policy 2: `allow authenticated select` - 僅認證用戶可查詢（iOS App）

3. ✅ 驗證路徑：使用 REST POST/GET 驗證策略（指令示例見 `README.md`）。
   - 自動化測試：`test_supabase_stage1.sh`
   - 手動測試範例：參考 `SETUP_GUIDE.md`

## 技術實作細節

### 資料表設計
- **主鍵**：`id int8` 使用 IDENTITY 自動遞增
- **時間戳記**：`created_at timestamptz` 預設為 `now()`
- **裝置識別**：`device_id text` 支持多裝置（如 tea_room_01, warehouse_A）
- **感測數據**：`temperature float4`, `humidity float4` 使用單精度浮點數節省空間

### 效能優化
- **索引 1**：`idx_readings_created_at` - 時間範圍查詢優化（DESC 排序）
- **索引 2**：`idx_readings_device_id` - 裝置篩選優化
- **查詢建議**：使用 `limit(288)` 限制返回數量（24小時 × 12筆/小時）

### 安全性設計
- **RLS 啟用**：所有查詢都經過 Row Level Security 檢查
- **最小權限原則**：ESP32 只能寫入，無法讀取歷史數據
- **認證隔離**：iOS App 必須透過 Auth 系統取得 token 才能讀取

### 可擴展性考量
- **多裝置支持**：透過 `device_id` 區分不同茶倉/房間
- **時區處理**：使用 `timestamptz` 自動處理時區轉換
- **資料保留**：未來可增加 `delete policy` 或定期清理舊資料

執行步驟與 SQL 請參考 [`TASKS_SUPABASE_STAGE_1.md`](TASKS_SUPABASE_STAGE_1.md) 和 [`SETUP_GUIDE.md`](SETUP_GUIDE.md)。

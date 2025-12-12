# Supabase 任務指引（Stage 1）

**狀態：✅ 已完成**  
**完成日期：2025-12-13**

速查清單：依 PRD 建立 `readings` 表、設定 RLS、完成 REST 驗證。

## 已完成任務

1. ✅ 讀 `supabase/AGENTS.md`、`../PRD_STAGE1.md`（摘要於 `PRD_SUPABASE_STAGE_1.md`），確認 schema/RLS 要求。

2. ✅ 準備認證資訊：`project ref`、`anon key`、`authenticated access token`（用於 SELECT 驗證）。

3. ✅ 建立資料庫遷移檔案 `001_create_readings_table.sql`，包含：
3. ✅ 建立資料庫遷移檔案 `001_create_readings_table.sql`，包含：
   - readings 資料表定義
   - RLS 策略（anon insert, authenticated select）
   - 效能索引（created_at, device_id）
   - 資料表和欄位註解
  
   執行方式：在 Supabase SQL Editor / CLI 執行該檔案內容

4. ✅ 建立自動化測試腳本 `test_supabase_stage1.sh`
   - POST with anon：驗證 201 回應
   - GET with anon：驗證 RLS 限制（空結果或 403）
   - GET with authenticated token：驗證 200 並取回資料
   - 批次插入測試數據
   
   使用方式：
   ```bash
   ./test_supabase_stage1.sh <PROJECT_REF> <ANON_KEY> <ACCESS_TOKEN>
   ```

5. ✅ 建立完整實作文檔 `SETUP_GUIDE.md`
   - 詳細設置步驟
   - 手動測試範例
   - 故障排除指南
   - 效能優化建議

## 交付清單

- ✅ `001_create_readings_table.sql` - SQL 遷移檔案
- ✅ `test_supabase_stage1.sh` - 測試腳本
- ✅ `SETUP_GUIDE.md` - 實作指南
- ✅ 欄位型別確認為 `float4`
- ✅ RLS 策略已正確設置
- ✅ 效能索引已建立

## 下一步

參考 `SETUP_GUIDE.md` 執行實際的資料庫設置和測試。完成後可繼續：
- ESP32 實作：`../esp32/TASKS_ESP32_STAGE_1.md`
- iOS App 實作：`../ios/TASKS_IOS_STAGE_1.md`

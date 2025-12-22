/\*

- File: README.md
- Purpose: Supabase Backend Project Overview and Development Guide
- Architecture: Supabase (PostgreSQL, RLS, REST API)
- AI Context: Source of truth for database schema and integration endpoints.
  \*/

# Supabase 專案概觀

**狀態：✅ Stage 1 已完成**

本目錄包含 1141-iOS-proj 專案的 Supabase 後端實作資訊，主要負責 IoT 感測數據的存儲與角色導向的資料存取控制。

## 🚀 快速連結

- **[Stage 1 實作詳情](STAGE_1.md)** - 資料表結構、RLS 策略與 PRD 摘要
- **[實作與測試指南](SETUP_GUIDE.md)** - 詳細的開發環境設置與驗證步驟
- **[SQL 遷移檔案](001_create_readings_table.sql)** - 用於重建資料庫結構的 SQL 指令

## 🛠 關鍵組件

- **資料表**: `readings` (存儲溫度、濕度與裝置 ID)
- **安全**: 啟用 RLS (Row Level Security)，區分 `anon` (寫入) 與 `authenticated` (讀取)
- **自動化**: 提供 `test_supabase_stage1.sh` 進行端到端 REST API 驗證

## 📖 開發原則

1. **冪等性 (Idempotency)**: 所有 SQL 遷移檔案必須支持重複執行而不報錯。
2. **最小權限 (Principle of Least Privilege)**: 強制執行 RLS，不論透過何種介面存取。
3. **文件同步**: 任何 Schema 變動必須同時更新 `AGENTS.md` 與對應的階段文件。

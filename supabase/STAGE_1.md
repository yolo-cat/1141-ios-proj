# Stage 1: Supabase 基礎建設

**狀態：✅ 已完成實作**  
**完成日期：2025-12-13**

---

## 1. 需求摘要 (PRD)

此階段建立後端感測數據存儲基礎架構。

### 核心規格

- **資料表**：`readings`
  - `id`: `int8` (Identity Primary Key)
  - `created_at`: `timestamptz` (Default: `now()`)
  - `device_id`: `text` (Not null)
  - `temperature`: `float4` (Not null)
  - `humidity`: `float4` (Not null)

### 權限要求

- 啟用 Row Level Security (RLS)
- **INSERT**: 允許 `anon` 角色寫入（供 ESP32 使用）
- **SELECT**: 僅 `authenticated` 角色可讀取（供 iOS App 使用）

---

## 2. 技術設計 (Design)

### 效能優化

- **索引**：
  - `idx_readings_created_at` (DESC)：優化時間範圍查詢
  - `idx_readings_device_id`：優化裝置篩選
- **查詢策略**：建議單次查詢上限為 288 筆（24小時歷史數據）。

### 安全性實作

- **最小權限**：ESP32 僅具備單向寫入權限，無法讀取歷史數據。
- **認證隔離**：App 端必須透過 Supabase Auth 取得 JWT 才能進行資料查詢。

---

## 3. 實作任務與交付 (Tasks)

### 已完成項目

- [x] 建立資料庫遷移檔案 `001_create_readings_table.sql`
- [x] 配置 RLS 策略與效能索引
- [x] 實作自動化測試腳本 `test_supabase_stage1.sh`
- [x] 撰寫 `SETUP_GUIDE.md` 完整設置指南

### 交付清單

- `001_create_readings_table.sql`
- `test_supabase_stage1.sh`
- `SETUP_GUIDE.md`

---

## 4. 驗證結果

| 測試情境   | 角色          | 預期結果         | 狀態 |
| :--------- | :------------ | :--------------- | :--- |
| 資料寫入   | anon          | HTTP 201 Created | ✅   |
| 資料讀取   | anon          | HTTP 403 / Empty | ✅   |
| 資料讀取   | authenticated | HTTP 200 OK      | ✅   |
| 冪等性執行 | admin         | 無報錯           | ✅   |

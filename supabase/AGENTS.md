/\*

- File: supabase/AGENTS.md
- Purpose: Supabase Sub-project Runtime Status and AI Collaboration Protocol
- Architecture: Postgres, RLS, Edge Functions
- AI Context: Backend synchronization and data integrity constraints.
  \*/

# Supabase 開發日誌 (AGENTS.md)

## 🎯 當前進度 (Done)

- ✅ **Stage 1: 基礎架構建立**
  - `readings` 資料表實作與 RLS 配置。
  - 效能索引佈署 (`created_at`, `device_id`)。
  - 自動化測試腳本與實作指南完成。
- ✅ **文檔整理 (Protocol Alignment)**
  - 整合 `STAGE_1.md` 並移除冗餘文件。
  - 核心文檔遵照 Gemini AI Agent Protocol 更新。

## 📝 任務開發筆記

- **2025-12-23**: 執行文檔整併，將所有階段一相關的細節 (PRD/Design/Tasks) 統一至 `STAGE_1.md`，以釋放 Context 空間並維持單一事實來源。

## 🚧 下一步 (Next Steps)

- [ ] **Stage 2: 高級查詢與分析**
  - 規劃聚合查詢 API (Hourly/Daily averages)。
  - 研究 Supabase Edge Functions 用於異常數據警報。
- [ ] **持續整合**
  - 將驗證腳本整合至專案工作流中。

---

## 📅 修改紀錄

- `2025-12-23`: 文檔結構優化，對齊 GEMINI.md 協議。
- `2025-12-13`: Stage 1 實作完成交付。

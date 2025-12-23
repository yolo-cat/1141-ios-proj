/\*

- File: AGENTS.md
- Purpose: AI Coding Agent 工作指南 (階段二)
- Architecture: Monorepo Indexing
- AI Context: Stage 2 focuses on Neon-Bento UI and Advanced Features.
  \*/

# AI Coding Agent 指南 (階段二)

本檔案提供 AI Coding Agent 在本倉庫執行工作的快速入口，並反映目前的開發狀態。

## 關鍵文檔 (Stage 2)

- [iOS 設計規格書](ios/Doc/stage-2-view/STAGE_2_IOS_DashboardView.md)：Neo-Bento 風格指引與組件規格。
- [設計提案：異常警報卡片](ios/Doc/stage-2-view/DESIGN_PROPOSALS_ALERT_CARD.md)：警報 UI 的視覺設計建議。

## 歷史存檔

- [stage-1.md](stage-1.md)：Stage 1 (MVP) 完整 PRD、設計與任務存檔。

## Stage 2 核心目標

- **UI/UX 重構**：採用 Neo-Bento 設計語音（高飽和度、飽滿圓角、非對稱網格）。
- **Dashboard 強化**：Hero Card (大數值即時數據)、Status Card (系統狀態圖標)。
- **視覺精品化**：移除冗餘註釋，提升代碼與文檔的一致性。

## 快速起手指令

- **Bento Card Modifier**:
  > "Create a SwiftUI ViewModifier `BentoCardStyle` that applies a continuous corner radius of 24, 16px padding, and a subtle floating shadow. Ensure it supports both Light and Dark mode backgrounds."
- **Hero Dashboard Card**:
  > "Using the `SensorViewModel`, create a 'Hero Card' that displays the current temperature in a large monospaced black font on an Indigo background, with a live breathing dot in the corner."

---

## 檔案架構

- `ios/`：SwiftUI App 重構主場。
- `supabase/`：後端資料表與 RLS 設定（Stage 1 已完成）。
- `esp32/`：感測器韌體（Stage 1 已完成）。

/\*

- File: AGENTS.md
- Purpose: Project Runtime Status and AI Collaboration Protocol (Stage 2)
- Architecture: Documentation-driven Development (PDCA)
- AI Context: Primary synchronization point for AI Agents. Tracks "Long-term Memory".
  \*/

# AI Coding Agent 工作指南 (AGENTS.md)

本檔案為 AI Agent 的核心工作區，記錄目前的開發狀態、關鍵決策與自動化指令。請嚴格遵守 [GEMINI.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/GEMINI.md) 協議。

## 🎯 當前進度 (Done)

- ✅ **Documentation Protocol**: 建立 `GEMINI.md` 並實作 AI 最佳化工作流 (`/update-readme`, `/update-agents`)。
- ✅ **Stage 2 Alignment**: 更新 `README.md` 以符合 Stage 2 (Neo-Bento UI) 索引與 Human-AI Balance 原則。
- ✅ **Stage 1 Archiving**: 所有的 MVP 相關文檔已封存至 `stage-1.md`。

## 🚧 下一步 (Next Steps)

- [ ] **Neo-Bento UI Implementation**: 依照 [iOS 設計規格書](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/Doc/stage-2-view/STAGE_2_IOS_DashboardView.md) 開始重構 Dashboard。
- [ ] **Alert Card Design**: 實作[設計提案](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/Doc/stage-2-view/DESIGN_PROPOSALS_ALERT_CARD.md)中的異常警報卡片。

## 📝 任務開發筆記

- **2025-12-23**: 導入 AI-Optimized Workflows。現在 AI Agent 可以透過 `.agent/workflows/` 中的標準流程來維護專案文檔。
- **2025-12-23**: 重構 `README.md`，導入 Monorepo 映射表與對 AI 友善的 Context 索引，確保跨模組開發的一致性。
- **2025-12-23**: 核心文檔對齊 `GEMINI.md` 規範，移除冗餘註釋，強化「代碼即文檔」的高訊息雜訊比。

## 快速起手指令 (Prompt Samples)

- **Bento Card Modifier**:
  > "Create a SwiftUI ViewModifier `BentoCardStyle` that applies a continuous corner radius of 24, 16px padding, and a subtle floating shadow. Ensure it supports both Light and Dark mode backgrounds."
- **Hero Dashboard Card**:
  > "Using the `SensorViewModel`, create a 'Hero Card' that displays the current temperature in a large monospaced black font on an Indigo background, with a live breathing dot in the corner."

---

## 📂 檔案架構速覽

- `ios/`：SwiftUI App 重構主場。
- `supabase/`：後端資料表與 RLS 設定（Stage 1 已完成）。
- `esp32/`：感測器韌體（Stage 1 已完成）。
- `.agent/workflows/`：專案專屬 AI 工作流。

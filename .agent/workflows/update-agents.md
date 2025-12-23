---
description: 更新 AGENTS.md 以作為 AI Agent 的「長期記憶」與工作指令集
---

# Workflow: Update AGENTS.md

本工作流用於維護 AI Agent 的執行日誌、未來任務與快速起手指令，確保跨對話的上下文一致性。

## 執行步驟

1. **Status Synchronization**:
   - 從當前對話或 `task.md` 提取已完成的任務、當前進度與下一步計畫。

2. **Memory Solidification**:
   - 更新 `🎯 當前進度 (Done)` 部分。
   - 更新 `🚧 下一步 (Next Steps)` 部分。
   - 在 `📝 任務開發筆記` 紀錄關鍵決策或架構變更。

3. **Prompt Optimization**:
   - 檢查 `快速起手指令` 是否仍適用於當前開發階段。
   - 如有新增的 UI 元件或 API，新增對應的 Prompt 範例。

4. **Protocol Compliance**:
   - 確保檔案開頭包含預期的 `AI-Optimized Header`。
   - 移除已過時的歷史細節（移至 `stage-x.md` 存檔）。

5. **Cleanup**:
   - 刪除冗餘註釋，確保「資訊雜訊比」最小化。

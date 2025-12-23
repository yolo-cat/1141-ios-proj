---
description: 檔案註釋與 Header 標準化工作流 (Enforcing GEMINI.md header and comment policy)
---

# 檔案註釋標準化工作流 (Code Commenting Workflow)

此 Workflow 用於確保程式碼檔案符合 [GEMINI.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/GEMINI.md) 規範，特別是 `AI-Optimized Header` 與 `Commenting Policy`。

---

## 步驟 1: 上下文掃描 (Context Scanning)

// turbo
讀取目標檔案，識別其功能、架構模式與關鍵依賴。

## 步驟 2: Header 注入/更新 (Header Injection & Update)

檢查或建立 `AI-Optimized Header`。

```text
/*
 * File: [檔案名稱]
 * Purpose: [核心功能]
 * Architecture: [Pattern (e.g., MVVM), Key Dependencies]
 * AI Context: [關鍵約束]
 */
```

- **File**: 必須是精確的檔案名稱與路徑（相對路徑）。
- **Purpose**: 高層次意圖（High-level intent），解釋 "Why" 而非 "How"。
- **Architecture**: 列出設計模式與核心依賴（例如：`SwiftUI`, `Supabase`, `MVVM`）。
- **AI Context**: 列出 AI Agent 必須知道的約束（例如：`Thread-safe`, `Immutable`, `MainActor-isolated`）。

## 步驟 3: 註釋淨化 (Comment Purification)

執行 `Commenting Policy`：

- [ ] **移除 Noise**: 刪除解釋語言語法、顯而易見邏輯（例如 `// loop through array`）或已過時的 TODO。
- [ ] **強化 Signal**: 確保複雜算法、邊界條件、隱性依賴或業務邏輯的 "Why" 有被清楚解釋。
- [ ] **格式檢查**: 使用 `✅ Good (High Signal)` 與 `❌ Bad (Noise)` 的標準進行自我審查。

## 步驟 4: 記憶同步 (AGENTS.md Sync)

// turbo
若此次註釋更新涉及重大邏輯釐清或決策記錄，必須同步更新 `AGENTS.md`。

---

## 使用範例

```bash
/code-commenting
請幫我標準化 ios/App/Views/DashboardView.swift 的註釋。
```

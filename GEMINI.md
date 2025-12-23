# Gemini AI Agent Protocol: High-Probability Success Model

## 0. Prime Directive (最高準則)

> **Context Integrity**: 文檔是專案的「長期記憶」。代碼與文檔的不一致視為 **Critical Failure**。
> **Token Economy**: 珍惜 Attention Window。只讀取必要文件，只輸出有效資訊。

---

## 1. Runtime Protocol (PDCA 循環)

### 🟢 [P] Step 1: Context Loading (上下文載入)

- **Check Truth**: 檢查根目錄 `AGENTS.md` 與 `README.md`。
- **Load Constraints**: 讀取並內化 Section 2 的「代碼規範」。

### 🟡 [D] Step 2: Execution (執行)

- **Constraint**: 嚴格遵守 `AI-Optimized Header` 格式。

### 🔵 [C] Step 3: Verification (驗證)

- **Check 1**: Header 是否存在且格式正確？
- **Check 2**: 新增的邏輯是否在 `AGENTS.md` 中有對應描述？
- **Check 3**: 是否移除了無意義的冗餘註釋 (Reduce Noise)？

### 🔴 [A] Step 4: Memory Solidification (記憶固化)

- **Action**: 更新 `README.md` 與 `AGENTS.md`。

---

## 2. Output Schema (輸出規範)

### 2.1 AI-Optimized Header

```text
/*
 * File: [檔案名稱]
 * Purpose: [核心功能 (High-Level Intent)]
 * Architecture: [Pattern (e.g., MVVM), Key Dependencies]
 * AI Context: [Critical Constraints (e.g., "Thread-safe", "Immutable")]
 */
```

### 2.2 Commenting Policy (註釋策略)

- **✅ Good (High Signal)**: 解釋複雜算法的邊界條件或隱性依賴。
- **❌ Bad (Noise)**: 解釋語法或顯而易見的邏輯。

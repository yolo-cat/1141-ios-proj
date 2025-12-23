---
description: 評估第三方套件/依賴導入可行性的標準流程
---

# 依賴導入可行性評估 (Dependency Feasibility Assessment)

當考慮導入新的 SPM 套件時，使用此 Workflow 進行系統性評估。

## 1. 收集套件資訊

請求使用者提供：

- 套件名稱與 GitHub README（或官方文檔連結）
- 已透過 SPM 安裝或僅在評估階段

## 2. 分析套件核心價值 (Core Value Proposition)

從 README 中提取：

- **Primary Use Cases**: 套件主要解決什麼問題？
- **Target Architecture**: 設計給什麼架構使用？(e.g., TCA, MVVM, MVC)
- **Key Features**: 核心 API 與功能列表

## 3. 掃描專案現況 (Project Context Scan)

// turbo
執行以下搜尋來了解專案使用模式：

```bash
# 搜尋專案中的 enum 使用 (for CasePaths)
grep -r "enum" --include="*.swift" .

# 搜尋導航相關 API (for Navigation)
grep -rE "NavigationStack|NavigationLink|sheet|fullScreenCover|alert|destination" --include="*.swift" .

# 列出 Views 數量與結構
find . -name "*.swift" -path "*/Views/*" | wc -l
```

### 關鍵文件審查清單

- [ ] `AGENTS.md` - 了解專案架構與開發原則
- [ ] `*App.swift` - App 入口與導航根結構
- [ ] `ViewModels/*.swift` - 狀態管理模式
- [ ] `Views/*.swift` - UI 層導航模式

## 4. 建立比較矩陣 (Comparison Matrix)

| 面向             | 套件設計目標             | 專案現況      | 差異評估    |
| ---------------- | ------------------------ | ------------- | ----------- |
| **架構模式**     | (e.g., TCA)              | (e.g., MVVM)  | 匹配/不匹配 |
| **Enum 複雜度**  | 巢狀 + Associated Values | 簡單 Enum     | 需要/不需要 |
| **導航深度**     | 多層 Destination         | 單層 Sheet    | 需要/不需要 |
| **Binding 解構** | Case-based Binding       | Bool/Optional | 需要/不需要 |

## 5. 成本效益分析 (Cost-Benefit Analysis)

### 導入成本

- [ ] 學習曲線 (Learning Curve)
- [ ] Macro 編譯開銷 (若使用 `@CasePathable` 等)
- [ ] 依賴維護 (Dependency Maintenance)
- [ ] 團隊熟悉度 (Team Familiarity)

### 預期收益

- [ ] 解決現有痛點？
- [ ] 提升代碼品質？
- [ ] 減少 Boilerplate？
- [ ] Deep Linking 支援？

## 6. 輸出評估報告

使用以下模板：

```markdown
## [套件名稱] 導入評估報告

### 📊 專案現況分析

| 面向           | 發現       |
| -------------- | ---------- |
| **[相關指標]** | [分析結果] |

### ⚠️ 結論：[建議/不建議]

#### 理由

1. [理由 1]
2. [理由 2]

### ✅ 何時需要重新評估？

- 情境 A
- 情境 B

### 🛠️ 建議操作

- [ ] [具體行動]
```

## 7. 後續行動

根據評估結果：

- **建議導入**: 更新 `AGENTS.md` 記錄決策，建立導入計畫
- **不建議導入**: 考慮移除 SPM 依賴，記錄評估理由供未來參考

---

## 使用範例

```
/evaluate-dependency

請提供套件 README 或 GitHub 連結，我將進行可行性評估。
```

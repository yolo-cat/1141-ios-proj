---
description: 建立高品質 AI Agent Workflow 的標準流程 (Meta-Workflow)
---

# Workflow 設計指南 (Workflow Design Guide)

此 Workflow 用於建立新的 AI Agent Workflow。基於業界最佳實踐編製。

---

## Phase 1: 需求釐清 (Requirement Clarification)

### 1.1 核心問題定義

詢問使用者：

- **任務目的**: 這個 Workflow 要解決什麼問題？
- **觸發情境**: 何時會使用這個 Workflow？
- **預期產出**: 執行完畢後應該產生什麼結果？

### 1.2 範圍界定 (Scope Definition)

- 是否需要外部工具？(API、CLI、Browser)
- 是否需要人工確認點？(Human-in-the-Loop)
- 預估執行時間與複雜度？

---

## Phase 2: 任務分解 (Task Decomposition)

> [!TIP]
> **核心原則**: 將複雜任務分解為可獨立執行的子步驟，每個步驟應具備明確的輸入/輸出。

### 2.1 分解策略選擇

| 策略         | 適用情境         | 範例                       |
| ------------ | ---------------- | -------------------------- |
| **線性序列** | 步驟有嚴格依賴   | 編譯 → 測試 → 部署         |
| **分支並行** | 獨立可並發的步驟 | 同時執行多個 lint 檢查     |
| **迭代迴圈** | 需要反覆改進     | Review → Refine → Validate |

### 2.2 步驟設計原則

每個步驟必須滿足：

- [ ] **原子性 (Atomic)**: 可獨立完成，不依賴中間狀態
- [ ] **可驗證 (Verifiable)**: 有明確完成條件
- [ ] **可恢復 (Recoverable)**: 失敗時可回滾或重試

### 2.3 粒度評估

- 太粗: 無法追蹤進度，難以除錯
- 太細: 增加 overhead，降低效率
- **建議**: 每個步驟 1-3 個工具呼叫

---

## Phase 3: 指令設計 (Instruction Design)

### 3.1 Prompt 撰寫最佳實踐

````markdown
# 好的指令範例 ✅

## 3. 執行代碼分析

// turbo
掃描 `src/` 目錄下所有 `.swift` 檔案，提取函數簽名。

```bash
grep -rn "func " --include="*.swift" src/
```
````

````

```markdown
# 差的指令範例 ❌
## 3. 分析代碼
看看代碼庫裡有什麼。
````

### 3.2 指令要素清單

| 要素         | 說明                                | 必要性    |
| ------------ | ----------------------------------- | --------- |
| **動作動詞** | 明確的行動 (e.g., 執行、建立、驗證) | ✅ 必要   |
| **對象**     | 操作目標 (e.g., 檔案、API、資料)    | ✅ 必要   |
| **約束條件** | 限制與邊界 (e.g., 只限 production)  | ⚠️ 視情況 |
| **預期輸出** | 完成標準 (e.g., 產生 JSON 報告)     | ⚠️ 視情況 |

### 3.3 Turbo 標註使用

```markdown
// turbo → 單一步驟可自動執行
// turbo-all → 整個 Workflow 所有命令可自動執行
```

> [!CAUTION]
> 只在「無副作用且安全」的命令上使用 `// turbo`。

---

## Phase 4: 驗證機制 (Verification Mechanism)

### 4.1 自我反思模式 (Reflection Pattern)

在關鍵步驟後加入驗證點：

```markdown
## 5. 驗證結果

確認上一步產生的檔案符合預期：

- [ ] 檔案存在且非空
- [ ] 格式正確 (JSON/YAML 可解析)
- [ ] 內容包含必要欄位
```

### 4.2 錯誤處理策略

| 錯誤類型   | 處理方式         |
| ---------- | ---------------- |
| 可恢復錯誤 | 提供重試指引     |
| 阻塞錯誤   | 請求使用者介入   |
| 預期外錯誤 | 記錄上下文並中止 |

---

## Phase 5: 文檔結構化 (Document Structuring)

### 5.1 Workflow 標準模板

````markdown
---
description: [一行描述此 Workflow 的用途]
---

# [Workflow 名稱]

[簡短說明使用情境與前置條件]

## 1. [步驟名稱]

[具體指令]

// turbo (若適用)

```bash
[可執行命令]
```
````

## 2. [步驟名稱]

...

---

## 使用範例

```
/[workflow-slug]
[說明如何發起此 Workflow]
```

````

### 5.2 命名規範

- **檔名**: `kebab-case.md` (e.g., `create-workflow.md`)
- **Slash Command**: `/kebab-case` (e.g., `/create-workflow`)
- **標題**: 中英文混用可接受，保持一致性

---

## Phase 6: 審查與迭代 (Review & Iteration)

### 6.1 自檢清單

在完成 Workflow 前，確認：

- [ ] 每個步驟都可在 5 分鐘內完成
- [ ] 沒有模糊的「視情況而定」指令
- [ ] 關鍵步驟有驗證機制
- [ ] 包含使用範例
- [ ] frontmatter 中有 `description`

### 6.2 真實場景測試

// turbo
```bash
# 驗證 Workflow 檔案格式正確
head -10 .agent/workflows/*.md
````

嘗試使用該 Workflow 執行一次完整流程，記錄：

- 卡住的步驟
- 不清楚的指令
- 缺少的上下文

### 6.3 持續改進

根據反饋更新 Workflow，每次改進記錄於：

- Workflow 頂部的版本日誌
- 或 Git Commit Message

---

## 使用範例

```
/create-workflow

我想建立一個用於 Code Review 的標準流程，請協助設計。
```

---

## 附錄: AI Agent Workflow 設計模式

| 模式                     | 說明                         | 適用場景       |
| ------------------------ | ---------------------------- | -------------- |
| **Prompt Chaining**      | 步驟串接，前步輸出為後步輸入 | 多階段處理     |
| **Parallelization**      | 獨立子任務並行執行           | 批量分析       |
| **Evaluator-Optimizer**  | 生成→評估→改進迴圈           | 內容創作       |
| **Orchestrator-Workers** | 主控分派任務給專職 Agent     | 複雜專案       |
| **Reflection**           | 自我審查與修正               | 需高準確度場景 |

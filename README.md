# TeaWarehouse-MVP (Stage 2)

本專案為 iOS 課程期末專題：**普洱茶倉環境監控系統 (Pu'er Sense)**。旨在結合 IoT 感測器與 iOS 現代化介面，實現茶葉儲存環境的精準監修。

## 🚀 專案狀態：Stage 2 (Neo-Bento UI Refactor)

目前專案正從 MVP 轉向更精緻的用戶體驗。

- **Core Focus**: 將 iOS App 重構為現代化的 **Neo-Bento (新便當盒風格)**。
- **Visuals**: 引入圖表視覺化（Charts）、組件化 Widget 與動態環境警報。
- **Logic**: 整合 Google OAuth 身份連結與 Supabase Realtime 即時同步。

---

## 🛠 AI Agent 核心指南 (Context for AI)

本專案深度依賴 AI 輔助開發，請務必遵守以下協議以確保「長期記憶」與「代碼一致性」：

- **PROTOCOL**: [GEMINI.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/GEMINI.md) - 核心代碼規範與 PDCA 循環流程。
- **MEMORY**: [AGENTS.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/AGENTS.md) - 當前開發進度、決策記錄與快速指令集。

### 標準工作流 (/slash-commands)

- `/update-readme`：更新本索引文件。
- `/update-agents`：更新開發日誌與進度。
- `/evaluate-dependency`：導入第三方庫前的評估。

---

## 📂 子專案與架構入口

本專案採單體倉庫 (Monorepo) 管理各端代碼：

| 模組           | 路徑                                                                            | 說明                                |
| :------------- | :------------------------------------------------------------------------------ | :---------------------------------- |
| **iOS Client** | [`ios/`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/)           | SwiftUI 專案，遵循 MVVM 架構。      |
| **Backend**    | [`supabase/`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/supabase/) | 資料庫架構、Edge Functions 與 RLS。 |
| **Firmware**   | [`esp32/`](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/esp32/)       | Arduino/C++ 韌體，用於感測與上傳。  |

### 歷史存檔

- [stage-1.md](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/stage-1.md)：Stage 1 (MVP) 需求與設計文檔備份。

---

© 2025 Pu'er Sense Team. Optimized for AI Collaboration.

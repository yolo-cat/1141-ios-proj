# AI Coding Agent 指南（Stage 1）

本檔案提供 AI Coding Agent 在本倉庫執行工作的快速入口，內容來源為 `stage_1_prd.md` 與 `stage_1_prompt.md`。

## 關鍵文件
- [stage_1_prd.md](../stage_1_prd.md)：完整 PRD，涵蓋硬體、後端、iOS App 功能需求與資料表結構。
- [stage_1_prompt.md](../stage_1_prompt.md)：可直接貼給 AI Agent 的啟動指令範例。

## PRD 摘要
- 專案：普洱茶倉環境監控系統（TeaWarehouse-MVP），重點在即時性、原生 iOS 體驗、資料視覺化。
- 技術堆疊：ESP32 + DHT11（C++/Arduino）、Supabase（PostgreSQL/RLS）、iOS 17+ / SwiftUI（`supabase-swift`、`Swift Charts`）。
- 資料表 `readings`：欄位 id、created_at、device_id、temperature、humidity；RLS 規則允許 anon 寫入、僅 authenticated 可讀取。
- ESP32 韌體：開機連 Wi-Fi、斷線自動重連；每 10 秒（Demo）讀取 DHT11，若 NaN 則略過；以 REST POST JSON 上傳至 Supabase。
- iOS App（MVVM）：Auth 登入/註冊；Dashboard 訂閱 `readings` INSERT 事件即時更新並在超標時發通知；History 以 Swift Charts 繪製最近資料折線。

## 快速起手指令（可直接貼給 Agent）
- Supabase SQL：見 `stage_1_prompt.md` 中的建表與 RLS 啟動指令。
- ESP32 範本：`stage_1_prompt.md` 提供 Wi-Fi 連線、DHT11 讀取、HTTP POST 至 Supabase 的範例提示。
- iOS ViewModel：`stage_1_prompt.md` 提供 `SensorViewModel`（Realtime 訂閱 + 歷史資料抓取）的範例提示。

## 目錄建議（參考）
未來若擴充程式碼，可依 PRD 附錄建議的結構建立 `TeaMonitorApp/` 底下的 Models、ViewModels、Views、Managers 目錄。

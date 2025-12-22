# TeaWarehouse-MVP iOS Stage 1 完整文檔

本文件整合了 Stage 1 階段的所有開發指引、需求摘要、設計架構、實作步驟與測試方案。

---

## 1. 開發指引 (原 AGENTS.md)

TeaWarehouse-MVP iOS 端採用 SwiftUI + MVVM，資料源來自 Supabase。

### 依據

- PRD：[`../../PRD_STAGE1.md`](../../PRD_STAGE1.md)（資料表 `readings`、Auth、Realtime、History 圖表）
- Prompt 範本：[`../../stage_1_prompt.md`](../../stage_1_prompt.md) 的 iOS 指令區段

### 原則

- **框架**：iOS 17+、Swift 5.9+、SwiftUI、`supabase-swift`、`Swift Charts`
- **架構**：MVVM，ViewModel 不直接持有 View
- **資料**：`readings` 欄位 `id | created_at | device_id | temperature | humidity`（PostgreSQL: float4；Swift: Float）
- **即時性**：Dashboard 需訂閱 Realtime `INSERT` 更新最新讀數
- **安全**：Anon 只用於寫入設備；App 讀取需 authenticated session

### Stage-1 必備輸出

1. Auth：Email/Password 登入與註冊，保存 Session
2. Supabase 客戶端單例（供 ViewModel 共用）
3. Model `Reading` 對應資料表
4. `DashboardViewModel`：訂閱 `readings` `INSERT`、維護 `currentReading`
5. 視圖：Dashboard（即時卡片 + 超標震動/通知）

---

## 2. 需求摘要 (原 PRD_IOS_STAGE_1.md)

此部分摘錄 Stage 1 的 iOS 需求。

- **功能**：
  - Auth：Email/Password 登入與註冊，保存 Session。
  - Dashboard：訂閱 `readings` Realtime `INSERT`，即時顯示最新溫/濕度，超標（Temp>30 或 Humidity>70）觸發震動/通知。
  - History：查詢排序後的歷史讀數（預設 288 筆或 Demo 100 筆），以雙折線圖呈現。
- **資料模型**：`id | created_at | device_id | temperature (Float) | humidity (Float)` 對應 Supabase `float4` 欄位。

---

## 3. 設計架構 (原 DESIGN_IOS_STAGE_1.md)

### 架構概要

1. 架構：SwiftUI + MVVM。`SupabaseManager` 單例提供 auth、realtime、查詢。
2. Model：`Reading` 對應 Supabase `readings` 欄位，使用 `Float` 表示溫/濕度。
3. ViewModels：
   - `AuthViewModel`：登入/註冊並維護 session。
   - `SensorViewModel`：訂閱 `readings` `INSERT` 更新 `currentReading`。
4. Views：
   - `LoginView` 驗證。
   - `DashboardView` 顯示最新數據並在超標時觸發震動/通知。

### 代碼對應

- App 入口：`../App/TeaWarehouseApp.swift`
- 模型與管理：`../App/Models/Reading.swift`、`../App/Managers/SupabaseManager.swift`
- ViewModels：`../App/ViewModels/AuthViewModel.swift`、`../App/ViewModels/DashboardViewModel.swift`
- 視圖：`../App/Views/LoginView.swift`、`../App/Views/DashboardView.swift`

---

## 4. 實作步驟 (原 TASKS_IOS_STAGE_1.md)

1. **初始化專案**：建立 SwiftUI App 專案，建立資料夾 `Models/`, `ViewModels/`, `Views/`, `Managers/`。
2. **加入依賴**：以 Swift Package Manager 新增 `supabase-swift`。
3. **設定 Supabase**：建立 `SupabaseManager` 單例，提供 auth、realtime、查詢入口。
4. **定義模型**：建立 `Reading`（對應 `readings` 欄位）。
5. **實作 Auth**：`AuthViewModel` 負責登入/註冊與 session 維護。
6. **即時資料**：`DashboardViewModel` 訂閱 Realtime `INSERT`。
7. **介面**：實作 `LoginView` 與 `DashboardView`（含震動/通知控）。
8. **驗證**：觀察 Realtime 更新與超標行為。

---

## 5. 測試方案 (原 TEST_IOS_STAGE1.md)

### 範圍與環境

- 目標：驗證登入/註冊流程、Realtime `INSERT` 訂閱、超標通知/震動。
- 前置：Supabase 環境配置，可使用 stub/mocks。

### 測試類型

1. **單元測試**：`SupabaseManager`, `AuthViewModel`, `DashboardViewModel`。
2. **整合測試**：以 mock 驗證 Realtime 更新 UI 狀態。
3. **UI/手動測試**：登入流程、Dashboard 即時跳動、超標提醒。

### 主要測試案例

- AUTH-001：有效帳密登入成功。
- REALTIME-001：模擬 `INSERT` 更新 `currentReading`。
- ALERT-001：超標時觸發震動/通知。

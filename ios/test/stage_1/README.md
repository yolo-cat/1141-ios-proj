# iOS Stage 1 測試骨架

此資料夾存放 Stage 1 的 XCTest 測試樣板，對應 `ios/TEST_IOS_STAGE1.md`。將檔案加入 Xcode test target 後，可依 TDD 逐項實作。

## 結構
- `AuthViewModelTests.swift`：登入/註冊、session 保存
- `SensorViewModelTests.swift`：Realtime 訂閱、歷史查詢、超標提醒

## 執行方式（建議）
1. 在專案中新增 Test Target，將本資料夾加入。
2. 提供 `SupabaseClient` mock（或以測試環境 URL/Key）以避免真實網路存取。
3. 依 `TEST_IOS_STAGE1.md` 的案例順序移除 `XCTSkip` 並填寫 Arrange/Act/Assert。

> 備註：目前範例以 `canImport(TeaWarehouse)` 條件避免在尚未建立 app module 時造成編譯錯誤。完成主程式後請移除此條件以啟用測試。

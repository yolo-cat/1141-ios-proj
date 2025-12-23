#if canImport(XCTest)
  import XCTest

  #if canImport(TeaWarehouse)
    @testable import TeaWarehouse

    final class DashboardViewModelTests: XCTestCase {
      func testRealtimeInsertUpdatesCurrentReading() throws {
        throw XCTSkip("移除跳過並注入 mock Realtime client 後啟用此測試。")
        // Arrange: 建立 DashboardViewModel 並以 mock Realtime 推播一筆 readings INSERT payload
        // Act: 觸發 callback
        // Assert: currentReading 已更新且 device_id/temperature/humidity/created_at 相符
      }

      func testHistoryQueryRespectsLimitAndSorting() throws {
        throw XCTSkip("移除跳過並注入 mock Supabase query 後啟用此測試。")
        // Arrange: mock 回傳超過上限的亂序資料
        // Act: 調用 fetchHistory(limit:)，預設 100/288
        // Assert: 回傳筆數不超過上限且依 created_at 升序排列
      }

      func testAlertTriggersWhenThresholdExceeded() throws {
        throw XCTSkip("移除跳過並串接 haptic/通知 mock 後啟用此測試。")
        // Arrange: 設定提醒閾值（Temp>30 或 Humidity>70），注入 haptic/通知 mock
        // Act: 推送一筆超標的 readings
        // Assert: mock 收到觸發事件，節節流時間內後續資料不重複觸發
      }
    }

  #else

    final class DashboardViewModelTests: XCTestCase {
      func testPendingUntilAppModuleExists() throws {
        throw XCTSkip("TeaWarehouse 模組尚未建立；導入 app target 後再啟用測試。")
      }
    }

  #endif
#endif

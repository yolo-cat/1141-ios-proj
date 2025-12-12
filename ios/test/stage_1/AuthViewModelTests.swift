#if canImport(XCTest)
import XCTest

#if canImport(TeaWarehouse)
@testable import TeaWarehouse

final class AuthViewModelTests: XCTestCase {
    func testSignInSuccessUpdatesSession() throws {
        throw XCTSkip("移除跳過並連接實際或 mock Supabase client 後啟用此測試。")
        // Arrange: 建立帶有假登入回應的 SupabaseClient mock
        // Act: 呼叫 signIn(email:password:) 並等待 completion
        // Assert: session 不為 nil，狀態為已登入，錯誤為 nil。
    }

    func testSignUpFailureReturnsError() throws {
        throw XCTSkip("移除跳過並連接實際或 mock Supabase client 後啟用此測試。")
        // Arrange: mock signUp 回傳錯誤
        // Act: 呼叫 signUp(email:password:)
        // Assert: session 維持為 nil，錯誤訊息已更新
    }

    func testSessionPersistsAcrossLaunch() throws {
        throw XCTSkip("移除跳過並連接實際或 mock Supabase client 後啟用此測試。")
        // Arrange: 注入已保存的 session
        // Act: 初始化 AuthViewModel
        // Assert: 自動帶入 session 並觸發狀態回呼
    }
}

#else

final class AuthViewModelTests: XCTestCase {
    func testPendingUntilAppModuleExists() throws {
        throw XCTSkip("TeaWarehouse 模組尚未建立；導入 app target 後再啟用測試。")
    }
}

#endif
#endif
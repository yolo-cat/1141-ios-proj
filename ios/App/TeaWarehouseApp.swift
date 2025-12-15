/// 2025-12-13: 改用 Observation 注入 AuthViewModel 並新增版本註釋。
#if canImport(SwiftUI)
import SwiftUI
import Observation

@main
struct TeaWarehouseApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authViewModel)
        }
    }
}
#endif

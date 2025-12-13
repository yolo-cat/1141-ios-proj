#if canImport(SwiftUI)
import SwiftUI

@main
struct TeaWarehouseApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
#endif

/// 2025-12-13: 改用 Observation 注入 AuthViewModel 並新增版本註釋。
#if canImport(SwiftUI)
import SwiftUI
import Observation

@main
struct TeaWarehouseApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var sensorViewModel = SensorViewModel.makeDefault()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.sessionToken == nil {
                    LoginView()
                } else {
                    TabView {
                        DashboardView(viewModel: sensorViewModel)
                            .tabItem { Label("Dashboard", systemImage: "waveform.path.ecg") }
                        HistoryChartView(viewModel: sensorViewModel)
                            .tabItem { Label("History", systemImage: "chart.line.uptrend.xyaxis") }
                    }
                }
            }
            .environment(authViewModel)
        }
    }
}
#endif

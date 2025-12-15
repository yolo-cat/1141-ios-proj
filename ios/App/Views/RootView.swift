/// 2025-12-13: 改用 Observation 環境注入 AuthViewModel 並更新版本註釋。
#if canImport(SwiftUI)
import SwiftUI
import Observation

struct RootView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var sensorViewModel = SensorViewModel.makeDefault()

    var body: some View {
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
    }
}
#endif

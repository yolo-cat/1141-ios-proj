#if canImport(SwiftUI)
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var sensorViewModel = SensorViewModel()

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

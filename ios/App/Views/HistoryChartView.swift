#if canImport(SwiftUI)
import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct HistoryChartView: View {
    @ObservedObject var viewModel: SensorViewModel

    var body: some View {
        VStack {
#if canImport(Charts)
            if viewModel.history.isEmpty {
                Text("No history yet").foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(viewModel.history) { reading in
                        LineMark(
                            x: .value("Time", reading.createdAt),
                            y: .value("Temp", reading.temperature)
                        )
                        .foregroundStyle(by: .value("Metric", "Temperature"))

                        LineMark(
                            x: .value("Time", reading.createdAt),
                            y: .value("Humidity", reading.humidity)
                        )
                        .foregroundStyle(by: .value("Metric", "Humidity"))
                    }
                }
                .chartLegend(.visible)
            }
#else
            Text("Charts framework not available in this environment.")
                .foregroundColor(.secondary)
#endif
        }
        .padding()
        .onAppear { viewModel.fetchHistory() }
    }
}
#endif

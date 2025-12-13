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
                let readings = viewModel.history
                var tempMin = readings.first?.temperature ?? 0
                var tempMax = tempMin
                var humMin = readings.first?.humidity ?? 0
                var humMax = humMin
                for reading in readings {
                    tempMin = min(tempMin, reading.temperature)
                    tempMax = max(tempMax, reading.temperature)
                    humMin = min(humMin, reading.humidity)
                    humMax = max(humMax, reading.humidity)
                }

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
                .accessibilityLabel("Temperature and humidity history chart")
                .accessibilityValue("Showing \(readings.count) points. Temperature from \(tempMin, specifier: "%.1f") to \(tempMax, specifier: "%.1f") degrees. Humidity from \(humMin, specifier: "%.1f") to \(humMax, specifier: "%.1f") percent.")
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

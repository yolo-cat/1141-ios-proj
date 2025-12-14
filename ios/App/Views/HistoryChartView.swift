/// 2025-12-13: 修正 onChange 簽名並維持 Observation 綁定。
#if canImport(SwiftUI)
import SwiftUI
import Observation
#if canImport(Charts)
import Charts
#endif

struct HistoryChartView: View {
    @Bindable var viewModel: SensorViewModel
    @State private var cachedStats: (tempMin: Float, tempMax: Float, humMin: Float, humMax: Float)?

    var body: some View {
        VStack {
#if canImport(Charts)
            if viewModel.history.isEmpty {
                Text("No history yet").foregroundColor(.secondary)
            } else if let stats = cachedStats {
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
                .accessibilityValue("Showing \(viewModel.history.count) points. Temperature from \(stats.tempMin, specifier: "%.1f") to \(stats.tempMax, specifier: "%.1f") degrees. Humidity from \(stats.humMin, specifier: "%.1f") to \(stats.humMax, specifier: "%.1f") percent.")
            } else if let stats = cacheAndReturnStats() {
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
                .accessibilityValue("Showing \(viewModel.history.count) points. Temperature from \(stats.tempMin, specifier: "%.1f") to \(stats.tempMax, specifier: "%.1f") degrees. Humidity from \(stats.humMin, specifier: "%.1f") to \(stats.humMax, specifier: "%.1f") percent.")
            }
#else
            Text("Charts framework not available in this environment.")
                .foregroundColor(.secondary)
#endif
        }
        .padding()
        .onAppear {
            viewModel.fetchDefaultHistory()
        }
        .onChange(of: viewModel.history, initial: false) { _, _ in
            cachedStats = computeStats()
        }
    }

    private func computeStats() -> (tempMin: Float, tempMax: Float, humMin: Float, humMax: Float)? {
        guard let first = viewModel.history.first else { return nil }
        var tempMin = first.temperature
        var tempMax = first.temperature
        var humMin = first.humidity
        var humMax = first.humidity
        for reading in viewModel.history.dropFirst() {
            tempMin = min(tempMin, reading.temperature)
            tempMax = max(tempMax, reading.temperature)
            humMin = min(humMin, reading.humidity)
            humMax = max(humMax, reading.humidity)
        }
        return (tempMin, tempMax, humMin, humMax)
    }

    private func cacheAndReturnStats() -> (tempMin: Float, tempMax: Float, humMin: Float, humMax: Float)? {
        if let cachedStats { return cachedStats }
        let computed = computeStats()
        cachedStats = computed
        return computed
    }
}
#endif

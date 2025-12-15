/// 2025-12-14: 新增 HistoryChart #Preview 預覽。
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

#Preview {
    HistoryChartView(viewModel: .previewHistory)
}

private extension SensorViewModel {
    static var previewHistory: SensorViewModel {
        let manager = MockSupabaseManager()
        let viewModel = SensorViewModel(manager: manager)
        let now = Date()
        viewModel.history = [
            Reading(id: 1, createdAt: now.addingTimeInterval(-300), deviceId: "tea_room_01", temperature: 21.2, humidity: 55.0),
            Reading(id: 2, createdAt: now.addingTimeInterval(-180), deviceId: "tea_room_01", temperature: 22.4, humidity: 56.5),
            Reading(id: 3, createdAt: now.addingTimeInterval(-60), deviceId: "tea_room_01", temperature: 23.1, humidity: 57.8)
        ]
        return viewModel
    }
}

private final class MockSupabaseManager: SupabaseManaging {
    var sessionToken: String? = nil

    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func fetchHistory(limit: Int) async throws -> [Reading] {
        let now = Date()
        let samples: [Reading] = [
            Reading(id: 1, createdAt: now.addingTimeInterval(-300), deviceId: "tea_room_01", temperature: 21.2, humidity: 55.0),
            Reading(id: 2, createdAt: now.addingTimeInterval(-180), deviceId: "tea_room_01", temperature: 22.4, humidity: 56.5),
            Reading(id: 3, createdAt: now.addingTimeInterval(-60), deviceId: "tea_room_01", temperature: 23.1, humidity: 57.8)
        ]
        return Array(samples.prefix(limit))
    }
    func signOut() {}

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
        Task { @MainActor in
            let readings = try? await fetchHistory(limit: limit)
            completion(.success(readings ?? []))
        }
    }

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {}
    func unsubscribeFromReadings() {}
}
#endif

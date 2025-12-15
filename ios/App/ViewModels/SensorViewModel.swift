/// 2025-12-13: 對接 async SupabaseManaging 並保持 @Observable。
#if canImport(Foundation)
import Foundation
import Observation

@MainActor
@Observable
final class SensorViewModel {
    var currentReading: Reading?
    var history: [Reading] = []
    var isSubscribed: Bool = false
    var lastAlertAt: Date?

    var temperatureThreshold: Float
    var humidityThreshold: Float
    var alertHandler: (() -> Void)?
    private var alertActive = false

    private let manager: SupabaseManaging

    init(
        manager: SupabaseManaging,
        temperatureThreshold: Float = StageConfig.temperatureThreshold,
        humidityThreshold: Float = StageConfig.humidityThreshold
    ) {
        self.manager = manager
        self.temperatureThreshold = temperatureThreshold
        self.humidityThreshold = humidityThreshold
    }

    static func makeDefault() -> SensorViewModel {
        SensorViewModel(manager: SupabaseManager.shared)
    }

    func startListening() {
        guard !isSubscribed else { return }
        manager.subscribeToReadings { [weak self] reading in
            Task { @MainActor in
                self?.handle(insert: reading)
            }
        }
        isSubscribed = true
    }

    func stopListening() {
        guard isSubscribed else { return }
        manager.unsubscribeFromReadings()
        isSubscribed = false
    }

    func fetchDefaultHistory() {
        fetchHistory(limit: StageConfig.historyLimit)
    }

    func fetchHistory(limit: Int) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let records = try await manager.fetchHistory(limit: limit)
                await MainActor.run {
                    self.history = records.sorted { $0.createdAt < $1.createdAt }
                }
            } catch {
                await MainActor.run { self.history = [] }
            }
        }
    }

    private func handle(insert reading: Reading) {
        currentReading = reading
        checkAlert(for: reading)
    }

    private func checkAlert(for reading: Reading) {
        let overTemp = reading.temperature > temperatureThreshold
        let overHum = reading.humidity > humidityThreshold
        guard overTemp || overHum else {
            alertActive = false
            return
        }

        let now = Date()
        if alertActive, let last = lastAlertAt, now.timeIntervalSince(last) < StageConfig.alertCooldown {
            return
        }
        lastAlertAt = now
        alertActive = true
        alertHandler?()
    }
}
#endif

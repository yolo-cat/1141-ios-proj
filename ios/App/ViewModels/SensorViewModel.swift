#if canImport(Foundation)
import Foundation

@MainActor
final class SensorViewModel: ObservableObject {
    @Published var currentReading: Reading?
    @Published var history: [Reading] = []
    @Published var isSubscribed: Bool = false
    @Published var lastAlertAt: Date?

    var temperatureThreshold: Float = StageConfig.temperatureThreshold
    var humidityThreshold: Float = StageConfig.humidityThreshold
    var alertHandler: (() -> Void)?
    private var alertActive = false

    private let manager: SupabaseManaging

    init(manager: SupabaseManaging = SupabaseManager.shared) {
        self.manager = manager
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

    func fetchHistory(limit: Int = StageConfig.historyLimit) {
        manager.fetchHistory(limit: limit) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let records):
                    self?.history = records.sorted { $0.createdAt < $1.createdAt }
                case .failure:
                    self?.history = []
                }
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

/*
 * File: DashboardViewModel.swift
 * Purpose: Provides sensor data aggregation, history fetching, and alert logic for the Dashboard.
 * Architecture: MVVM (ViewModel) using @Observable. Interacts with SupabaseManager for streaming/history.
 * AI Context: Logic for temperature/humidity alerts resides here. Check StageConfig for thresholds.
 */
#if canImport(Foundation)
  import Foundation
  import Observation

  @MainActor
  @Observable
  final class DashboardViewModel {
    /// Alert types for sensor readings
    enum AlertType {
      case normal
      case temperature
      case humidity
      case both

      var title: String {
        switch self {
        case .normal: return "正常"
        case .temperature, .humidity, .both: return "警報"
        }
      }

      var description: String {
        switch self {
        case .normal: return "所有系統運作正常。"
        case .temperature: return "溫度超過閾值。"
        case .humidity: return "濕度超過閾值。"
        case .both: return "溫濕度警報。"
        }
      }

      var isCritical: Bool {
        self != .normal
      }
    }

    var currentReading: Reading?
    var history: [Reading] = []
    var isSubscribed: Bool = false
    var lastAlertAt: Date?
    var alertType: AlertType = .normal
    var devices: [DeviceInfo] = []

    var temperatureThreshold: Float
    var humidityThreshold: Float
    var alertHandler: (() -> Void)?

    // Internal state to track if an alert has been triggered continuously
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

    /// 感測裝置資訊結構
    struct DeviceInfo: Identifiable, Equatable {
      /// 裝置唯一 ID
      let id: String
      /// 安裝位置
      let location: String
      /// 狀態（上線/離線）
      let status: Status
      /// 電池電量百分比
      let battery: Int

      /// 裝置狀態列舉
      enum Status {
        case online, offline
      }
    }

    static func makeDefault() -> DashboardViewModel {
      DashboardViewModel(manager: SupabaseManager.shared)
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
            let sortedHistory = records.sorted { $0.createdAt < $1.createdAt }
            self.history = sortedHistory
            // Initial data population if real-time hasn't triggered yet
            if self.currentReading == nil {
              self.currentReading = sortedHistory.last
              if let last = sortedHistory.last {
                self.checkAlert(for: last)
              }
            }
          }
        } catch {
          // DEBUG: Log error for diagnosis
          print("❌ [DashboardViewModel] fetchHistory error: \(error)")
          await MainActor.run { self.history = [] }
        }
      }
    }

    private func handle(insert reading: Reading) {
      currentReading = reading
      checkAlert(for: reading)
    }

    func checkAlert(for reading: Reading) {
      let overTemp = reading.temperature > temperatureThreshold
      let overHum = reading.humidity > humidityThreshold

      if overTemp && overHum {
        alertType = .both
      } else if overTemp {
        alertType = .temperature
      } else if overHum {
        alertType = .humidity
      } else {
        alertType = .normal
      }

      guard alertType.isCritical else {
        alertActive = false
        return
      }

      let now = Date()
      if alertActive, let last = lastAlertAt,
        now.timeIntervalSince(last) < StageConfig.alertCooldown
      {
        return
      }
      lastAlertAt = now
      alertActive = true
      alertHandler?()
    }
  }
#endif

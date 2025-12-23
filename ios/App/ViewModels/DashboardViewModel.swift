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
    var userEmail: String?

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

    func fetchUserProfile() {
      Task { [weak self] in
        guard let self else { return }
        do {
          let email = try await manager.currentUserEmail()
          await MainActor.run { self.userEmail = email }
        } catch {
          print("❌ [DashboardViewModel] fetchUserProfile error: \(error)")
        }
      }
    }

    func fetchHistory(limit: Int) {
      Task { [weak self] in
        guard let self else { return }
        do {
          let records = try await manager.fetchHistory(limit: limit)
          await MainActor.run {
            let sortedHistory = records.sorted { $0.createdAt < $1.createdAt }
            self.history = sortedHistory
            // 每次 fetch 都更新 currentReading 以同步 Hero/Context/Alert Card
            if let latest = sortedHistory.last {
              self.currentReading = latest
              self.checkAlert(for: latest)
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
      // 同步更新歷史列表
      history.append(reading)
      // 保持列表在限制數量內
      if history.count > StageConfig.historyLimit {
        history.removeFirst(history.count - StageConfig.historyLimit)
      }
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

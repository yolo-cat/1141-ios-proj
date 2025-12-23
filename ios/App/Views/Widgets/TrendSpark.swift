/*
 * File: TrendSpark.swift
 * Purpose: Mini sparkline chart with trend arrow indicator for temperature/humidity.
 * Architecture: SwiftUI View + Swift Charts. Uses DesignSystem tokens.
 * AI Context: Computes trend from recent readings. Stateless, receives data array.
 */

#if canImport(SwiftUI)
  import SwiftUI
  import Charts

  /// 方案 C：迷你走勢線組件
  /// 顯示微型折線圖 + 趨勢箭頭，適合 Grid Cell 或列表項
  struct TrendSpark: View {
    /// 數據類型
    enum DataType {
      case temperature
      case humidity

      var color: Color {
        switch self {
        case .temperature: return DesignSystem.Colors.primary
        case .humidity: return DesignSystem.Colors.accentB
        }
      }

      var icon: String {
        switch self {
        case .temperature: return "thermometer.medium"
        case .humidity: return "drop.fill"
        }
      }

      var unit: String {
        switch self {
        case .temperature: return "°C"
        case .humidity: return "%"
        }
      }
    }

    /// 趨勢方向
    enum Trend {
      case up, down, stable

      var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
      }

      var color: Color {
        switch self {
        case .up: return DesignSystem.Colors.danger  // 上升 = 警告
        case .down: return DesignSystem.Colors.accentB  // 下降 = 回歸正常
        case .stable: return DesignSystem.Colors.textSecondary
        }
      }
    }

    let dataType: DataType
    let readings: [Reading]

    /// 可選：顯示圖標
    var showIcon: Bool = true

    /// 可選：Sparkline 高度
    var sparklineHeight: CGFloat = 24

    // MARK: - Computed Properties

    private var currentValue: Float {
      guard let latest = readings.sorted(by: { $0.createdAt < $1.createdAt }).last else { return 0 }
      return dataType == .temperature ? latest.temperature : latest.humidity
    }

    private var dataPoints: [(date: Date, value: Float)] {
      readings.sorted(by: { $0.createdAt < $1.createdAt }).map { reading in
        (reading.createdAt, dataType == .temperature ? reading.temperature : reading.humidity)
      }
    }

    private var trend: Trend {
      guard readings.count >= 10 else { return .stable }
      let sorted = readings.sorted(by: { $0.createdAt < $1.createdAt })

      let recentValues = sorted.suffix(5).map {
        dataType == .temperature ? $0.temperature : $0.humidity
      }
      let previousValues = sorted.dropLast(5).suffix(5).map {
        dataType == .temperature ? $0.temperature : $0.humidity
      }

      guard !recentValues.isEmpty, !previousValues.isEmpty else { return .stable }

      let recentAvg = recentValues.reduce(0, +) / Float(recentValues.count)
      let previousAvg = previousValues.reduce(0, +) / Float(previousValues.count)
      let delta = recentAvg - previousAvg

      if delta > 0.5 { return .up }
      if delta < -0.5 { return .down }
      return .stable
    }

    private var deltaValue: Float {
      guard readings.count >= 2 else { return 0 }
      let sorted = readings.sorted(by: { $0.createdAt < $1.createdAt })
      guard let latest = sorted.last, let previous = sorted.dropLast().last else { return 0 }

      let latestVal = dataType == .temperature ? latest.temperature : latest.humidity
      let previousVal = dataType == .temperature ? previous.temperature : previous.humidity
      return latestVal - previousVal
    }

    // MARK: - Body

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        // 數值 + 趨勢
        HStack(spacing: 8) {
          if showIcon {
            Image(systemName: dataType.icon)
              .font(.caption)
              .foregroundStyle(dataType.color)
          }

          Text(String(format: "%.1f%@", currentValue, dataType.unit))
            .font(DesignSystem.Typography.cardTitle)
            .foregroundStyle(dataType.color)

          // 趨勢指示器
          HStack(spacing: 2) {
            Image(systemName: trend.icon)
              .font(.caption.bold())
            Text(String(format: "%+.1f", deltaValue))
              .font(.caption.monospacedDigit())
          }
          .foregroundStyle(trend.color)
        }

        // Sparkline
        if dataPoints.count >= 2 {
          Chart(dataPoints, id: \.date) { point in
            LineMark(
              x: .value("Time", point.date),
              y: .value("Value", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(dataType.color)
            .lineStyle(StrokeStyle(lineWidth: 2))
          }
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .frame(height: sparklineHeight)
        } else {
          // 數據不足時顯示佔位
          Rectangle()
            .fill(DesignSystem.Colors.textSecondary.opacity(0.1))
            .frame(height: sparklineHeight)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
      }
    }
  }

  // MARK: - Previews

  #Preview("Temperature Trend") {
    let mockReadings = (0..<12).map { i in
      Reading(
        id: Int64(i),
        createdAt: Date().addingTimeInterval(Double(-i) * 3600),
        deviceId: "ESP-01",
        temperature: 22 + Float.random(in: -2...3),
        humidity: 55 + Float.random(in: -5...5)
      )
    }

    return VStack(spacing: 24) {
      TrendSpark(dataType: .temperature, readings: mockReadings)
        .padding()
        .background(DesignSystem.Colors.cardStandard)
        .clipShape(RoundedRectangle(cornerRadius: 16))

      TrendSpark(dataType: .humidity, readings: mockReadings)
        .padding()
        .background(DesignSystem.Colors.cardStandard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(24)
    .background(DesignSystem.Colors.canvas)
  }

  #Preview("Compact") {
    let mockReadings = (0..<6).map { i in
      Reading(
        id: Int64(i),
        createdAt: Date().addingTimeInterval(Double(-i) * 1800),
        deviceId: "ESP-01",
        temperature: 24 + Float(i) * 0.3,
        humidity: 60
      )
    }

    return HStack(spacing: 16) {
      TrendSpark(dataType: .temperature, readings: mockReadings, sparklineHeight: 20)
        .frame(maxWidth: .infinity)

      TrendSpark(dataType: .humidity, readings: mockReadings, sparklineHeight: 20)
        .frame(maxWidth: .infinity)
    }
    .padding()
    .background(DesignSystem.Colors.cardStandard)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding(24)
    .background(DesignSystem.Colors.canvas)
  }
#endif

/*
 * File: ComparisonPill.swift
 * Purpose: Compact dual-indicator capsule widget displaying temperature and humidity side-by-side.
 * Architecture: SwiftUI View, follows DesignSystem tokens. Reusable in HStack or as standalone.
 * AI Context: Pure UI component. Receives Reading data, no business logic.
 */

#if canImport(SwiftUI)
  import SwiftUI

  /// 方案 B：雙指標膠囊組件
  /// 緊湊地並排顯示溫度與濕度，適合 Banner、Header 或列表項
  struct ComparisonPill: View {
    let temperature: Float
    let humidity: Float

    /// 可選：顯示圖標
    var showIcons: Bool = true

    /// 可選：緊湊模式（更小字體）
    var isCompact: Bool = false

    var body: some View {
      HStack(spacing: 0) {
        // 溫度區塊
        HStack(spacing: 6) {
          if showIcons {
            Image(systemName: "thermometer.medium")
              .font(isCompact ? .caption : .body)
              .foregroundStyle(DesignSystem.Colors.primary)
          }
          Text(String(format: "%.1f°C", temperature))
            .font(isCompact ? .callout.bold().monospacedDigit() : .title3.bold().monospacedDigit())
            .foregroundStyle(DesignSystem.Colors.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 8 : 12)

        // 分隔線
        Rectangle()
          .fill(DesignSystem.Colors.textSecondary.opacity(0.2))
          .frame(width: 1)
          .padding(.vertical, 8)

        // 濕度區塊
        HStack(spacing: 6) {
          if showIcons {
            Image(systemName: "drop.fill")
              .font(isCompact ? .caption : .body)
              .foregroundStyle(DesignSystem.Colors.accentB)
          }
          Text(String(format: "%.0f%%", humidity))
            .font(isCompact ? .callout.bold().monospacedDigit() : .title3.bold().monospacedDigit())
            .foregroundStyle(DesignSystem.Colors.accentB)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 8 : 12)
      }
      .background(DesignSystem.Colors.cardStandard)
      .clipShape(Capsule())
      .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
  }

  // MARK: - Convenience Initializers

  extension ComparisonPill {
    /// 從 Reading 初始化
    init(reading: Reading, showIcons: Bool = true, isCompact: Bool = false) {
      self.temperature = reading.temperature
      self.humidity = reading.humidity
      self.showIcons = showIcons
      self.isCompact = isCompact
    }

    /// 從可選 Reading 初始化，提供預設值
    init(reading: Reading?, showIcons: Bool = true, isCompact: Bool = false) {
      self.temperature = reading?.temperature ?? 0
      self.humidity = reading?.humidity ?? 0
      self.showIcons = showIcons
      self.isCompact = isCompact
    }
  }

  // MARK: - Previews

  #Preview("Standard") {
    VStack(spacing: 20) {
      ComparisonPill(temperature: 24.5, humidity: 60)
        .padding(.horizontal, 24)

      ComparisonPill(temperature: 28.3, humidity: 75, showIcons: false)
        .padding(.horizontal, 24)
    }
    .padding(.vertical, 40)
    .background(DesignSystem.Colors.canvas)
  }

  #Preview("Compact") {
    VStack(spacing: 12) {
      ComparisonPill(temperature: 24.5, humidity: 60, isCompact: true)
      ComparisonPill(temperature: 25.0, humidity: 58, isCompact: true)
      ComparisonPill(temperature: 23.8, humidity: 62, isCompact: true)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(DesignSystem.Colors.canvas)
  }
#endif

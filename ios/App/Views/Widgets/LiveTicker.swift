/*
 * File: LiveTicker.swift
 * Purpose: Animated numeric display with slot-machine style rolling effect on value change.
 * Architecture: SwiftUI View using contentTransition (iOS 17+) with fallback for earlier versions.
 * AI Context: Uses DesignSystem tokens. Wrap any numeric display for animation effect.
 */

#if canImport(SwiftUI)
  import SwiftUI

  /// 方案 D：滾動數字動畫組件
  /// 數值變化時呈現老虎機式滾動效果
  struct LiveTicker: View {
    /// 數值類型
    enum ValueType {
      case temperature
      case humidity
      case custom(color: Color, unit: String)

      var color: Color {
        switch self {
        case .temperature: return DesignSystem.Colors.primary
        case .humidity: return DesignSystem.Colors.accentB
        case .custom(let color, _): return color
        }
      }

      var unit: String {
        switch self {
        case .temperature: return "°C"
        case .humidity: return "%"
        case .custom(_, let unit): return unit
        }
      }

      var format: String {
        switch self {
        case .temperature: return "%.1f"
        case .humidity: return "%.0f"
        case .custom: return "%.1f"
        }
      }
    }

    /// 字體尺寸預設
    enum Size {
      case hero  // 48pt - 用於 HeroDataCard
      case large  // 34pt - 標題級
      case medium  // 24pt - 一般卡片
      case small  // 18pt - 列表項

      var font: Font {
        switch self {
        case .hero: return DesignSystem.Typography.heroNumber
        case .large: return .system(size: 34, weight: .bold, design: .rounded)
        case .medium: return .system(size: 24, weight: .bold, design: .monospaced)
        case .small: return DesignSystem.Typography.cardTitle
        }
      }

      var unitFont: Font {
        switch self {
        case .hero: return .title2.bold()
        case .large: return .title3.bold()
        case .medium: return .body.bold()
        case .small: return .caption.bold()
        }
      }
    }

    let value: Float
    let valueType: ValueType
    var size: Size = .medium

    /// 可選：顯示單位
    var showUnit: Bool = true

    /// 動畫配置
    private let animation = Animation.spring(response: 0.4, dampingFraction: 0.8)

    var body: some View {
      HStack(alignment: .firstTextBaseline, spacing: 2) {
        // 數值 (帶滾動動畫)
        if #available(iOS 17.0, *) {
          Text(String(format: valueType.format, value))
            .font(size.font)
            .foregroundStyle(valueType.color)
            .contentTransition(.numericText())
            .animation(animation, value: value)
        } else {
          // iOS 16 fallback: 使用 id 觸發重繪動畫
          Text(String(format: valueType.format, value))
            .font(size.font)
            .foregroundStyle(valueType.color)
            .id(value)
            .transition(
              .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
              )
            )
            .animation(animation, value: value)
        }

        // 單位
        if showUnit {
          Text(valueType.unit)
            .font(size.unitFont)
            .foregroundStyle(valueType.color.opacity(0.6))
        }
      }
    }
  }

  // MARK: - Convenience Initializers

  extension LiveTicker {
    /// 溫度快捷初始化
    static func temperature(_ value: Float, size: Size = .medium) -> LiveTicker {
      LiveTicker(value: value, valueType: .temperature, size: size)
    }

    /// 濕度快捷初始化
    static func humidity(_ value: Float, size: Size = .medium) -> LiveTicker {
      LiveTicker(value: value, valueType: .humidity, size: size)
    }
  }

  // MARK: - Interactive Preview

  #Preview("Live Update Demo") {
    struct DemoView: View {
      @State private var temperature: Float = 24.5
      @State private var humidity: Float = 60

      var body: some View {
        VStack(spacing: 32) {
          // Hero Size
          VStack(spacing: 8) {
            Text("HERO SIZE")
              .font(DesignSystem.Typography.label())
              .foregroundStyle(DesignSystem.Colors.textSecondary)

            LiveTicker.temperature(temperature, size: .hero)
          }

          // Medium Size with both values
          HStack(spacing: 40) {
            VStack(spacing: 4) {
              Text("TEMP")
                .font(.caption.bold())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
              LiveTicker.temperature(temperature, size: .medium)
            }

            VStack(spacing: 4) {
              Text("HUMIDITY")
                .font(.caption.bold())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
              LiveTicker.humidity(humidity, size: .medium)
            }
          }
          .padding()
          .background(DesignSystem.Colors.cardStandard)
          .clipShape(RoundedRectangle(cornerRadius: 16))

          // Small Size
          HStack(spacing: 24) {
            LiveTicker.temperature(temperature, size: .small)
            LiveTicker.humidity(humidity, size: .small)
          }

          // Controls
          VStack(spacing: 16) {
            Button("Simulate Update") {
              withAnimation {
                temperature += Float.random(in: -1...1)
                humidity += Float.random(in: -5...5)
              }
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.Colors.primary)

            Button("Reset") {
              withAnimation {
                temperature = 24.5
                humidity = 60
              }
            }
            .buttonStyle(.bordered)
          }
        }
        .padding(32)
        .background(DesignSystem.Colors.canvas)
      }
    }

    return DemoView()
  }

  #Preview("All Sizes") {
    VStack(alignment: .leading, spacing: 24) {
      Group {
        Text("Hero").font(.caption.bold()).foregroundStyle(.secondary)
        LiveTicker.temperature(24.5, size: .hero)
      }

      Divider()

      Group {
        Text("Large").font(.caption.bold()).foregroundStyle(.secondary)
        LiveTicker.temperature(24.5, size: .large)
      }

      Divider()

      Group {
        Text("Medium").font(.caption.bold()).foregroundStyle(.secondary)
        LiveTicker.temperature(24.5, size: .medium)
      }

      Divider()

      Group {
        Text("Small").font(.caption.bold()).foregroundStyle(.secondary)
        LiveTicker.temperature(24.5, size: .small)
      }
    }
    .padding(24)
    .background(DesignSystem.Colors.canvas)
  }
#endif

/*
 * File: com_puer_sense.swift
 * Purpose: Main Home Screen Widget implementation for latest temperature and humidity.
 * Architecture: WidgetKit extension.
 * AI Context: Uses simplified versions of DesignSystem tokens for Home Screen compatibility.
 */

import SwiftUI
import WidgetKit

// MARK: - Simplified Design System for Widget
enum WidgetDesign {
  static let primary = Color(hex: "5856D6")  // Indigo (Temperature)
  static let accentB = Color(hex: "32D74B")  // Green (Humidity)
  static let canvas = Color("Canvas")
  static let card = Color("CardStandard")

  enum Typography {
    static let value = Font.system(size: 24, weight: .bold, design: .rounded)
    static let label = Font.system(size: 12, weight: .bold, design: .rounded)
  }
}

// MARK: - Widget Provider
struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), temperature: 24.5, humidity: 60, status: "Normal")
  }

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry
  {
    SimpleEntry(date: Date(), temperature: 24.5, humidity: 60, status: "Normal")
  }

  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
    SimpleEntry
  > {
    // In a real app, this would fetch from Supabase or AppGroup defaults
    let entry = SimpleEntry(date: Date(), temperature: 24.5, humidity: 60, status: "Normal")
    return Timeline(entries: [entry], policy: .atEnd)
  }
}

// MARK: - Entry Model
struct SimpleEntry: TimelineEntry {
  let date: Date
  let temperature: Float
  let humidity: Float
  let status: String
}

// MARK: - Widget View
struct com_puer_senseEntryView: View {
  var entry: Provider.Entry
  @Environment(\.widgetFamily) var family

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        Text("PU'ER SENSE")
          .font(WidgetDesign.Typography.label)
          .foregroundStyle(.secondary)
          .tracking(1.5)
        Spacer()
        Circle()
          .fill(WidgetDesign.accentB)
          .frame(width: 8, height: 8)
      }

      Spacer()

      // Content based on size
      if family == .systemSmall {
        smallView
      } else {
        mediumView
      }

      Spacer()

      // Footer
      Text(entry.date, style: .time)
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(.secondary)
    }
    .padding()
    .containerBackground(WidgetDesign.canvas, for: .widget)
  }

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 4) {
        Image(systemName: "thermometer.medium")
          .foregroundStyle(WidgetDesign.primary)
        Text(String(format: "%.1f°", entry.temperature))
          .font(WidgetDesign.Typography.value)
          .foregroundStyle(WidgetDesign.primary)
      }

      HStack(spacing: 4) {
        Image(systemName: "drop.fill")
          .foregroundStyle(WidgetDesign.accentB)
        Text(String(format: "%.0f%%", entry.humidity))
          .font(WidgetDesign.Typography.value)
          .foregroundStyle(WidgetDesign.accentB)
      }
    }
  }

  private var mediumView: some View {
    HStack(spacing: 20) {
      // Left: Large Temp
      VStack(alignment: .leading) {
        Text("TEMPERATURE")
          .font(.system(size: 10, weight: .black))
          .foregroundStyle(WidgetDesign.primary.opacity(0.8))
        Text(String(format: "%.1f°C", entry.temperature))
          .font(.system(size: 34, weight: .black, design: .rounded))
          .foregroundStyle(WidgetDesign.primary)
      }

      Divider()

      // Right: Humidity & Status
      VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading) {
          Text("HUMIDITY")
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(WidgetDesign.accentB.opacity(0.8))
          Text(String(format: "%.0f%%", entry.humidity))
            .font(.title2.bold())
            .foregroundStyle(WidgetDesign.accentB)
        }

        Text(entry.status)
          .font(.caption.bold())
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(WidgetDesign.accentB.opacity(0.1))
          .foregroundStyle(WidgetDesign.accentB)
          .clipShape(Capsule())
      }
    }
  }
}

// MARK: - Widget Configuration
struct com_puer_sense: Widget {
  let kind: String = "ZZT.ios.widget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
      entry in
      com_puer_senseEntryView(entry: entry)
    }
    .configurationDisplayName("Pu'er Sense")
    .description("Monitoring your tea warehouse climate.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Extensions
extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default: (a, r, g, b) = (1, 1, 1, 0)
    }
    self.init(
      .sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255,
      opacity: Double(a) / 255)
  }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
  com_puer_sense()
} timeline: {
  SimpleEntry(date: .now, temperature: 24.5, humidity: 60, status: "Normal")
}

#Preview(as: .systemMedium) {
  com_puer_sense()
} timeline: {
  SimpleEntry(date: .now, temperature: 25.8, humidity: 55, status: "Normal")
}

/*
 * File: com_puer_sense.swift
 * Purpose: Main Home Screen Widget implementation for latest temperature and humidity.
 * Architecture: WidgetKit extension using StaticConfiguration (simpler, more compatible).
 * AI Context: Simplified to avoid AppIntent issues in Xcode 26 beta.
 */

import SwiftUI
import WidgetKit

// MARK: - Simplified Design System for Widget
enum WidgetDesign {
  static let primary = Color(red: 0.345, green: 0.337, blue: 0.839)  // Indigo
  static let accentB = Color(red: 0.196, green: 0.843, blue: 0.294)  // Green
  static let canvas = Color(uiColor: .systemGroupedBackground)

  enum Typography {
    static let value = Font.system(size: 24, weight: .bold, design: .rounded)
    static let label = Font.system(size: 12, weight: .bold, design: .rounded)
  }
}

// MARK: - Simple Timeline Provider (No AppIntent)
struct SimpleProvider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), temperature: 24.5, humidity: 60)
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), temperature: 24.5, humidity: 60)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    let entry = SimpleEntry(date: Date(), temperature: 24.5, humidity: 60)
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - Entry Model
struct SimpleEntry: TimelineEntry {
  let date: Date
  let temperature: Float
  let humidity: Float
}

// MARK: - Widget View
struct WidgetEntryView: View {
  var entry: SimpleEntry
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

      // Content
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

      Spacer()

      // Footer
      Text(entry.date, style: .time)
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(.secondary)
    }
    .padding()
    .containerBackground(WidgetDesign.canvas, for: .widget)
  }
}

// MARK: - Widget Configuration (Static, No AppIntent)
struct com_puer_sense: Widget {
  let kind: String = "ZZT.ios.widget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
      WidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Pu'er Sense")
    .description("Monitoring your tea warehouse climate.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
  com_puer_sense()
} timeline: {
  SimpleEntry(date: .now, temperature: 24.5, humidity: 60)
}

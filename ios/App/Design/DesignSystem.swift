/*
 * File: DesignSystem.swift
 * Purpose: Centralized design tokens for the Neo-Bento UI system.
 * Architecture: Enum namespaces for Colors, Fonts, and Layouts.
 * AI Context: Defines the "Neo-Bento" visual language (Bold, High Saturation, Asymmetrical).
 */

import SwiftUI

/// Neo-Bento Design System
enum DesignSystem {

  // MARK: - Colors

  enum Colors {
    /// `#F2F2F7` (Light) / `#1C1C1E` (Dark)
    static let canvas = Color("Canvas")

    /// `#FFFFFF` (Light) / `#2C2C2E` (Dark)
    static let cardStandard = Color("CardStandard")

    /// `#5856D6` (Indigo) - Hero elements and key actions
    static let primary = Color(hex: "5856D6")

    /// `#FFD60A` (Yellow) - Attention, Warning
    static let accentA = Color(hex: "FFD60A")

    /// `#32D74B` (Green) - Success, Normal Status
    static let accentB = Color(hex: "32D74B")

    /// `#FF3B30` (Red) - Danger, Alert
    static let danger = Color(hex: "FF3B30")

    /// Secondary Text Color
    static let textSecondary = Color.secondary
  }

  // MARK: - Typography

  enum Typography {
    /// Size: 48, Weight: Black, Design: Monospaced
    static let heroNumber = Font.system(size: 48, weight: .black, design: .monospaced)

    /// Size: 34, Weight: Heavy, Design: Rounded
    static let header = Font.system(size: 34, weight: .heavy, design: .rounded)

    /// Size: 18, Weight: Bold
    static let cardTitle = Font.system(size: 18, weight: .bold)

    /// Caption, Uppercase, Tracking 2.0
    static func label() -> Font {
      return Font.caption.weight(.bold)
    }
  }

  // MARK: - Layout

  enum Layout {
    static let cornerRadius: CGFloat = 24
    static let gridSpacing: CGFloat = 16
    static let padding: CGFloat = 24
    static let inputHeight: CGFloat = 64
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
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

struct NeoBentoCard: ViewModifier {
  var backgroundColor: Color

  func body(content: Content) -> some View {
    content
      .background(backgroundColor)
      .clipShape(
        RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius, style: .continuous)
      )
      .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
  }
}

extension View {
  func neoBentoCard(color: Color = DesignSystem.Colors.cardStandard) -> some View {
    self.modifier(NeoBentoCard(backgroundColor: color))
  }
}

struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
      .opacity(configuration.isPressed ? 0.9 : 1.0)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
  }
}

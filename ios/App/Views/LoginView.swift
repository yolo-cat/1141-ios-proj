/*
 * File: LoginView.swift
 * Purpose: Authentication entry point with a tactile, premium UI design.
 * Architecture: SwiftUI View using @Environment for AuthViewModel.
 * AI Context: UI-only. Handles user input for login/signup flows.
 */
#if canImport(SwiftUI)
  import SwiftUI
  import Observation
  import CoreHaptics
  import UIKit

  // MARK: - Design System

  enum DesignSystem {
    static let teaDark = Color(red: 0.28, green: 0.15, blue: 0.10)
    static let teaBase = Color(red: 0.40, green: 0.22, blue: 0.15)
    static let teaHighlight = Color(red: 0.55, green: 0.35, blue: 0.25)
    static let paperWhite = Color(red: 0.96, green: 0.96, blue: 0.95)
    static let shadowColor = Color.black.opacity(0.15)

    static let fontStandard = Font.system(.body, design: .rounded)
    static let fontTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
  }

  // MARK: - Utilities

  extension Color {
    fileprivate init(hex: String) {
      let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
      var int: UInt64 = 0
      Scanner(string: hex).scanHexInt64(&int)
      let a: UInt64
      let r: UInt64
      let g: UInt64
      let b: UInt64
      switch hex.count {
      case 3:
        (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
      case 6:
        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
      case 8:
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

  // MARK: - Core Components

  /// Programmatic Pu'er tea cake illustration
  struct PuerTeaCakeView: View {
    let diameter: CGFloat

    var body: some View {
      ZStack {
        Canvas { context, size in
          let center = CGPoint(x: size.width / 2, y: size.height / 2)
          let radius = size.width / 2
          context.clip(to: Path(ellipseIn: CGRect(origin: .zero, size: size)))

          let baseGradient = Gradient(colors: [DesignSystem.teaHighlight, DesignSystem.teaDark])
          context.fill(
            Path(ellipseIn: CGRect(origin: .zero, size: size)),
            with: .radialGradient(baseGradient, center: center, startRadius: 0, endRadius: radius)
          )

          for _ in 0..<500 {
            let angle = Double.random(in: 0...(.pi * 2))
            let dist = Double.random(in: 0...radius)
            let x = center.x + CGFloat(cos(angle) * dist)
            let y = center.y + CGFloat(sin(angle) * dist)
            let leafSize = Double.random(in: 2...6)
            let opacity = Double.random(in: 0.1...0.4)
            let leafRect = CGRect(x: x, y: y, width: leafSize, height: leafSize * 0.7)
            context.fill(
              Path(ellipseIn: leafRect),
              with: .color(DesignSystem.teaDark.opacity(opacity))
            )
          }

          context.stroke(
            Path(ellipseIn: CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)),
            with: .color(Color.black.opacity(0.3)),
            lineWidth: 4
          )
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: DesignSystem.shadowColor, radius: 18, x: 10, y: 12)

        Circle()
          .fill(DesignSystem.paperWhite)
          .frame(width: diameter * 0.25, height: diameter * 0.25)
          .overlay {
            Text("茶")
              .font(.system(size: diameter * 0.12, weight: .heavy, design: .serif))
              .foregroundColor(DesignSystem.teaDark.opacity(0.8))
          }
          .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
      }
    }
  }

  /// Inner-shadow text field for tactile feel
  struct TactileTextField: View {
    var iconName: String
    var placeholder: String
    var isSecure: Bool = false
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
      HStack(spacing: 14) {
        Image(systemName: iconName)
          .foregroundColor(DesignSystem.teaBase.opacity(0.65))
          .font(.system(size: 18))

        Group {
          if isSecure {
            SecureField(placeholder, text: $text)
          } else {
            TextField(placeholder, text: $text)
              .textContentType(.emailAddress)
              .keyboardType(.emailAddress)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
        }
        .font(DesignSystem.fontStandard)
        .foregroundColor(DesignSystem.teaDark)
        .tint(DesignSystem.teaBase)
        .focused($isFocused)
      }
      .padding()
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "#F2F2F7"))

          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.black.opacity(0.12), lineWidth: 4)
            .blur(radius: 4)
            .offset(x: 2, y: 2)
            .mask(
              RoundedRectangle(cornerRadius: 16)
                .fill(
                  LinearGradient(
                    colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            )

          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.75), lineWidth: 2)
            .blur(radius: 2)
            .offset(x: -1, y: -1)
            .mask(
              RoundedRectangle(cornerRadius: 16)
                .fill(
                  LinearGradient(
                    colors: [.black, .clear], startPoint: .bottomTrailing, endPoint: .topLeading)
                )
            )
        }
      )
      .scaleEffect(isFocused ? 0.985 : 1.0)
      .animation(.spring(response: 0.3), value: isFocused)
    }
  }

  /// Floating tactile button with press feedback
  struct TactileButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack(spacing: 8) {
          if isLoading {
            ProgressView()
              .tint(.white)
          }
          Text(title)
            .font(.headline)
            .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
          ZStack {
            RoundedRectangle(cornerRadius: 22)
              .fill(
                LinearGradient(
                  colors: [DesignSystem.teaHighlight, DesignSystem.teaBase],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )

            RoundedRectangle(cornerRadius: 22)
              .fill(Color.white.opacity(0.12))
              .padding(.top, 2)
              .padding(.horizontal, 2)
              .mask(
                LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
              )
          }
        )
        .shadow(color: DesignSystem.teaDark.opacity(0.3), radius: 10, x: 0, y: 8)
      }
      .buttonStyle(PressScaleButtonStyle())
      .sensoryFeedback(.impact(weight: .medium), trigger: isLoading == false)
    }
  }

  struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.9 : 1.0)
        .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
  }

  // MARK: - Login View

  /// TeaWarehouse Login with tactile styling and tea-cake hero
  struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isSignUp = false
    @State private var formOpacity: Double = 0
    @State private var formOffset: CGFloat = 40

    var body: some View {
      @Bindable var authViewModel = authViewModel

      ZStack {
        DesignSystem.paperWhite
          .ignoresSafeArea()

        VStack(spacing: 18) {
          Spacer(minLength: 24)

          PuerTeaCakeView(diameter: 180)
            .rotationEffect(.degrees(12))
            .shadow(color: DesignSystem.shadowColor.opacity(0.6), radius: 14, x: 0, y: 10)

          VStack(spacing: 6) {
            Text("TeaWarehouse")
              .font(DesignSystem.fontTitle)
              .foregroundColor(DesignSystem.teaDark)
            Text(isSignUp ? "建立新帳號 · 普洱靈韻" : "普洱靈韻 · 倉儲管家")
              .font(.subheadline)
              .foregroundColor(DesignSystem.teaBase.opacity(0.7))
              .tracking(2)
          }
          .padding(.bottom, 8)

          VStack(spacing: 18) {
            TactileTextField(
              iconName: "envelope.fill",
              placeholder: "電子郵件",
              text: $authViewModel.email
            )

            TactileTextField(
              iconName: "lock.fill",
              placeholder: "密碼",
              isSecure: true,
              text: $authViewModel.password
            )

            if let error = authViewModel.errorMessage, !error.isEmpty {
              Text(error)
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            } else if let status = authViewModel.statusMessage, !status.isEmpty {
              Text(status)
                .font(.caption)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }

            TactileButton(
              title: isSignUp ? "註冊並登入" : "登入",
              isLoading: authViewModel.isLoading
            ) {
              triggerHaptic()
              if isSignUp {
                authViewModel.signUp()
              } else {
                authViewModel.signIn()
              }
            }

            Button(action: {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isSignUp.toggle()
              }
            }) {
              HStack(spacing: 4) {
                Text(isSignUp ? "已有帳號？" : "新用戶？")
                  .foregroundColor(DesignSystem.teaBase)
                Text(isSignUp ? "返回登入" : "立即註冊")
                  .fontWeight(.bold)
                  .foregroundColor(DesignSystem.teaHighlight)
              }
              .font(.footnote)
            }
            .padding(.top, 4)
          }
          .padding(24)
          .background(
            RoundedRectangle(cornerRadius: 24)
              .fill(.white)
              .shadow(color: DesignSystem.shadowColor, radius: 18, x: 0, y: 10)
          )
          .opacity(formOpacity)
          .offset(y: formOffset)

          Spacer()

          Text("Powered by ESP32 & SwiftUI")
            .font(.caption2)
            .foregroundColor(.gray.opacity(0.6))
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
      }
      .onAppear {
        withAnimation(.easeOut(duration: 0.6).delay(0.25)) {
          formOpacity = 1
          formOffset = 0
        }
      }
    }

    private func triggerHaptic() {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
    }
  }

  #Preview {
    let vm = AuthViewModel()
    vm.email = "demo@teawarehouse.app"
    vm.password = "password"
    return LoginView()
      .environment(vm)
  }
#endif

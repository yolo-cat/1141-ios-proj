/*
 * File: LoginView.swift
 * Purpose: Authentication entry point with Neo-Bento design.
 * Architecture: SwiftUI View using @Environment for AuthViewModel.
 * AI Context: UI-only. Handles user input for login/signup flows.
 */
#if canImport(SwiftUI)
  import SwiftUI
  import Observation
  import CoreHaptics
  import UIKit

  // MARK: - Login View

  /// Neo-Bento Login Screen
  struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isSignUp = false
    @State private var formOpacity: Double = 0
    @State private var formOffset: CGFloat = 40
    @FocusState private var focusedField: Field?

    enum Field {
      case email, password
    }

    var body: some View {
      @Bindable var authViewModel = authViewModel

      ZStack {
        // 1. Canvas
        DesignSystem.Colors.canvas
          .ignoresSafeArea()
          .onTapGesture {
            focusedField = nil
          }

        VStack(spacing: 0) {
          Spacer()

          // 2. Hero Typography
          VStack(spacing: 8) {
            Text("PU'ER")
              .font(Font.system(size: 70, weight: .black, design: .rounded))
              .foregroundStyle(
                LinearGradient(
                  colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)

            Text("SENSE")
              .font(DesignSystem.Typography.label())
              .foregroundColor(DesignSystem.Colors.textSecondary)
              .tracking(8)
          }
          .padding(.bottom, 60)
          .scaleEffect(formOpacity)  // Subtle pop-in

          // 3. Form
          VStack(spacing: 24) {
            // Email Input
            NeoInput(
              icon: "envelope.fill",
              placeholder: "Email",
              text: $authViewModel.email
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            // Password Input
            NeoInput(
              icon: "lock.fill",
              placeholder: "Password",
              text: $authViewModel.password,
              isSecure: true
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
              if !authViewModel.isLoading {
                performAction()
              }
            }

            // Status Messages
            if let error = authViewModel.errorMessage, !error.isEmpty {
              Label(error, systemImage: "exclamationmark.triangle.fill")
                .font(.caption.bold())
                .foregroundColor(DesignSystem.Colors.danger)
                .padding(.top, -8)
            } else if let status = authViewModel.statusMessage, !status.isEmpty {
              Label(status, systemImage: "checkmark.circle.fill")
                .font(.caption.bold())
                .foregroundColor(DesignSystem.Colors.accentB)
                .padding(.top, -8)
            }

            // Action Button
            Button(action: { performAction() }) {
              HStack {
                if authViewModel.isLoading {
                  ProgressView()
                    .tint(.white)
                    .padding(.trailing, 8)
                }
                Text(isSignUp ? "CREATE ACCOUNT" : "SIGN IN")
                  .fontWeight(.black)
              }
              .frame(maxWidth: .infinity)
              .frame(height: DesignSystem.Layout.inputHeight)
              .background(DesignSystem.Colors.primary)
              .foregroundColor(.white)
              .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius, style: .continuous)
              )
              .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(authViewModel.isLoading)

            // Divider
            HStack {
              Rectangle().fill(DesignSystem.Colors.textSecondary).frame(height: 1).opacity(0.1)
              Text("OR").font(.caption2).fontWeight(.bold).foregroundColor(
                DesignSystem.Colors.textSecondary)
              Rectangle().fill(DesignSystem.Colors.textSecondary).frame(height: 1).opacity(0.1)
            }
            .padding(.vertical, 4)

            // Google Button
            Button(action: { authViewModel.signInWithGoogle() }) {
              HStack {
                // Using a symbol as a placeholder for Google Logo
                Image(systemName: "globe")
                  .symbolRenderingMode(.hierarchical)
                  .foregroundColor(DesignSystem.Colors.primary)
                Text("Continue with Google")
                  .fontWeight(.bold)
                  .foregroundColor(DesignSystem.Colors.textSecondary)
              }
              .frame(maxWidth: .infinity)
              .frame(height: DesignSystem.Layout.inputHeight)
              .background(DesignSystem.Colors.cardStandard)
              .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius, style: .continuous)
              )
              .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
              .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius)
                  .stroke(DesignSystem.Colors.textSecondary.opacity(0.1), lineWidth: 1)
              )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(authViewModel.isLoading)

            // Toggle Mode
            Button(action: {
              withAnimation(.spring()) {
                isSignUp.toggle()
              }
            }) {
              HStack(spacing: 4) {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                  .foregroundColor(DesignSystem.Colors.textSecondary)
                Text(isSignUp ? "Sign In" : "Sign Up")
                  .fontWeight(.bold)
                  .foregroundColor(DesignSystem.Colors.primary)
              }
              .font(.footnote)
            }
            .padding(.top, 10)
          }
          .padding(.horizontal, 32)
          .opacity(formOpacity)
          .offset(y: formOffset)

          Spacer()
          Spacer()
        }
      }
      .onAppear {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
          formOpacity = 1
          formOffset = 0
        }
      }
    }

    private func performAction() {
      triggerHaptic()
      if isSignUp {
        authViewModel.signUp()
      } else {
        authViewModel.signIn()
      }
    }

    private func triggerHaptic() {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
    }
  }

  // MARK: - Components

  /// Tactile Neo-Bento Input
  struct NeoInput: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
      HStack(spacing: 16) {
        Image(systemName: icon)
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(DesignSystem.Colors.textSecondary)
          .frame(width: 24)

        Group {
          if isSecure {
            SecureField(placeholder, text: $text)
          } else {
            TextField(placeholder, text: $text)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
              .keyboardType(.emailAddress)
          }
        }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(DesignSystem.Colors.canvas.opacity(0.9) == .black ? .white : .black)  // Adaptive
      }
      .padding(.horizontal, 24)
      .frame(height: DesignSystem.Layout.inputHeight)
      .background(DesignSystem.Colors.cardStandard)
      // Neo-Bento Shadow/Depth
      .clipShape(
        RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius, style: .continuous)
      )
      .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
      .overlay(
        RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius)
          .stroke(DesignSystem.Colors.textSecondary.opacity(0.1), lineWidth: 1)
      )
    }
  }

  #Preview {
    let vm = AuthViewModel()
    return LoginView()
      .environment(vm)
  }
#endif

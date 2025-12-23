/*
 * File: ProfileView.swift
 * Purpose: User profile screen displaying email, linked identities, and account actions.
 * Architecture: SwiftUI View using @Bindable for ProfileViewModel. Features Neo-Bento styling.
 * AI Context: UI-only. All identity linking logic resides in ProfileViewModel.
 */

#if canImport(Foundation)
  import SwiftUI
  import Observation
  import Supabase

  struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
      NavigationStack {
        ZStack {
          // Background
          DesignSystem.Colors.canvas.ignoresSafeArea()

          ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Layout.gridSpacing) {
              // Avatar & Email Section
              profileHeaderCard

              // Linked Identities Section
              identitiesCard

              // Actions Section
              actionsCard
            }
            .padding(DesignSystem.Layout.padding)
          }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") { dismiss() }
              .fontWeight(.semibold)
              .foregroundColor(DesignSystem.Colors.primary)
          }
        }
        .onAppear {
          viewModel.fetchProfile()
        }
        .alert(
          "錯誤",
          isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
          )
        ) {
          Button("OK", role: .cancel) {}
        } message: {
          Text(viewModel.errorMessage ?? "")
        }
        .alert(
          "成功",
          isPresented: .init(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
          )
        ) {
          Button("OK", role: .cancel) {}
        } message: {
          Text(viewModel.successMessage ?? "")
        }
      }
    }

    // MARK: - Profile Header Card

    private var profileHeaderCard: some View {
      VStack(spacing: 16) {
        // Avatar
        Circle()
          .fill(
            LinearGradient(
              colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)
          .overlay(
            Text(String(viewModel.email?.prefix(1).uppercased() ?? "?"))
              .font(.system(size: 32, weight: .bold, design: .rounded))
              .foregroundColor(.white)
          )
          .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)

        // Email
        if let email = viewModel.email {
          Text(email)
            .font(.headline)
            .foregroundColor(DesignSystem.Colors.textSecondary)
        } else if viewModel.isLoading {
          ProgressView()
        } else {
          Text("Unknown")
            .font(.headline)
            .foregroundColor(DesignSystem.Colors.textSecondary)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 24)
      .neoBentoCard()
    }

    // MARK: - Identities Card

    private var identitiesCard: some View {
      VStack(alignment: .leading, spacing: 16) {
        // Header
        HStack {
          Text("LINKED ACCOUNTS")
            .font(DesignSystem.Typography.label())
            .foregroundColor(DesignSystem.Colors.textSecondary)
          Spacer()
        }

        Divider()

        // Identity List
        if viewModel.isLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .padding()
        } else if viewModel.identities.isEmpty {
          Text("No linked accounts")
            .font(.subheadline)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding()
        } else {
          ForEach(viewModel.identities, id: \.id) { identity in
            identityRow(for: identity)
          }
        }

        // Link Google Button (if not linked)
        if !viewModel.hasGoogleLinked && !viewModel.isLoading {
          Divider()
          Button(action: { viewModel.linkGoogle() }) {
            HStack {
              // Using a symbol as a placeholder for Google Logo
              Image(systemName: "globe")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(DesignSystem.Colors.primary)
              Text("連結 Google 帳號")
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
          .disabled(viewModel.isLoading)
        }
      }
      .padding(DesignSystem.Layout.padding)
      .neoBentoCard()
    }

    private func identityRow(for identity: UserIdentity) -> some View {
      HStack(spacing: 12) {
        // Provider Icon
        Image(systemName: iconName(for: identity.provider))
          .font(.title2)
          .foregroundColor(iconColor(for: identity.provider))
          .frame(width: 40, height: 40)
          .background(iconColor(for: identity.provider).opacity(0.1))
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text(displayName(for: identity.provider))
            .font(.headline)
            .foregroundColor(DesignSystem.Colors.textSecondary)
          if let email = identity.identityData?["email"]?.value as? String {
            Text(email)
              .font(.caption)
              .foregroundColor(DesignSystem.Colors.textSecondary)
          }
        }

        Spacer()

        // Status Badge
        Text("已連結")
          .font(.caption.bold())
          .foregroundColor(DesignSystem.Colors.primary)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(DesignSystem.Colors.primary.opacity(0.1))
          .clipShape(Capsule())
      }
      .padding(.vertical, 8)
    }

    // MARK: - Actions Card

    private var actionsCard: some View {
      VStack(spacing: 12) {
        Button(action: {
          viewModel.signOut()
          authViewModel.signOut()
          dismiss()
        }) {
          HStack {
            Image(systemName: "rectangle.portrait.and.arrow.right")
              .font(.title3)
            Text("登出")
              .fontWeight(.semibold)
            Spacer()
          }
          .foregroundColor(DesignSystem.Colors.danger)
          .padding()
          .background(DesignSystem.Colors.danger.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
      }
      .padding(DesignSystem.Layout.padding)
      .neoBentoCard()
    }

    // MARK: - Helpers

    private func iconName(for provider: String) -> String {
      switch provider.lowercased() {
      case "google": return "globe"
      case "apple": return "apple.logo"
      case "email": return "envelope.fill"
      default: return "person.fill"
      }
    }

    private func iconColor(for provider: String) -> Color {
      switch provider.lowercased() {
      case "google": return DesignSystem.Colors.primary
      case "apple": return .primary
      case "email": return DesignSystem.Colors.primary
      default: return DesignSystem.Colors.textSecondary
      }
    }

    private func displayName(for provider: String) -> String {
      switch provider.lowercased() {
      case "google": return "Google"
      case "apple": return "Apple"
      case "email": return "Email"
      default: return provider.capitalized
      }
    }
  }

  // MARK: - Preview

  #Preview {
    let vm = ProfileViewModel()
    vm.email = "test@example.com"
    return ProfileView(viewModel: vm)
      .environment(AuthViewModel())
  }
#endif

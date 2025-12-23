/*
 * File: ProfileViewModel.swift
 * Purpose: Manages user profile state and identity linking operations.
 * Architecture: MVVM (ViewModel) using @Observable and async/await.
 * AI Context: Handles identity linking for OAuth providers. Interacts with SupabaseManager.
 */
#if canImport(Foundation)
  import Foundation
  import Observation
  import Supabase

  @MainActor
  @Observable
  final class ProfileViewModel {
    var email: String?
    var identities: [UserIdentity] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var successMessage: String?

    private let manager: SupabaseManaging

    init(manager: SupabaseManaging = SupabaseManager.shared) {
      self.manager = manager
    }

    // MARK: - Computed Properties

    var hasGoogleLinked: Bool {
      identities.contains { $0.provider == "google" }
    }

    var hasEmailLinked: Bool {
      identities.contains { $0.provider == "email" }
    }

    // MARK: - Actions

    func fetchProfile() {
      isLoading = true
      errorMessage = nil
      Task { [weak self] in
        guard let self else { return }
        do {
          async let emailTask = self.manager.currentUserEmail()
          async let identitiesTask = self.manager.userIdentities()
          let (fetchedEmail, fetchedIdentities) = try await (emailTask, identitiesTask)
          await MainActor.run {
            self.email = fetchedEmail
            self.identities = fetchedIdentities
            self.isLoading = false
          }
        } catch {
          await MainActor.run {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
          }
        }
      }
    }

    func linkGoogle() {
      isLoading = true
      errorMessage = nil
      successMessage = nil
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.manager.linkIdentity(provider: .google)
          // After linking, refresh identities
          let newIdentities = try await self.manager.userIdentities()
          await MainActor.run {
            self.identities = newIdentities
            self.isLoading = false
            self.successMessage = "Google 帳號已連結成功！"
          }
        } catch {
          await MainActor.run {
            self.isLoading = false
            self.errorMessage = "連結失敗：\(error.localizedDescription)"
          }
        }
      }
    }

    func signOut() {
      manager.signOut()
    }
  }
#endif

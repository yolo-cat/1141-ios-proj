/*
 * File: AuthViewModel.swift
 * Purpose: Manages authentication state and business logic for Login/Signup.
 * Architecture: MVVM (ViewModel) using @Observable and async/await.
 * AI Context: Handles session lifecycle. Interacts with SupabaseManager.
 */
#if canImport(Foundation)
  import Foundation
  import Observation
  import Supabase

  @MainActor
  @Observable
  final class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var statusMessage: String?
    var sessionToken: String?

    private let manager: SupabaseManaging

    init(manager: SupabaseManaging = SupabaseManager.shared) {
      self.manager = manager
      self.sessionToken = manager.sessionToken
    }

    func signIn() {
      errorMessage = nil
      statusMessage = nil
      isLoading = true
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.manager.signIn(email: self.email, password: self.password)
          await MainActor.run {
            self.sessionToken = self.manager.sessionToken
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

    func signUp() {
      errorMessage = nil
      statusMessage = nil
      isLoading = true
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.manager.signUp(email: self.email, password: self.password)
          await MainActor.run {
            self.isLoading = false
            self.statusMessage = "Sign up succeeded. Please sign in after verification."
          }
        } catch {
          await MainActor.run {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
          }
        }
      }
    }

    func signInWithGoogle() {
      print("👤 [AuthViewModel] signInWithGoogle triggered.")
      errorMessage = nil
      statusMessage = nil
      isLoading = true
      Task { [weak self] in
        guard let self else { return }
        do {
          print("👤 [AuthViewModel] calling manager.signInWithOAuth(.google)")
          try await self.manager.signInWithOAuth(
            provider: .google,
            redirectTo: SupabaseManager.defaultRedirectURL
          )
          print("👤 [AuthViewModel] manager.signInWithOAuth returned. Polling for session...")

          // Polling for session token update from SupabaseManager listener
          var attempts = 0
          while self.manager.sessionToken == nil && attempts < 10 {
            print("👤 [AuthViewModel] Waiting for session... attempt \(attempts + 1)")
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s
            attempts += 1
          }

          if let token = self.manager.sessionToken {
            print("👤 [AuthViewModel] Session confirmed!")
            self.sessionToken = token
            self.isLoading = false
          } else {
            print("👤 [AuthViewModel] Timed out waiting for session.")
            self.isLoading = false
            self.errorMessage = "Login timed out or failed."
          }
        } catch {
          print("❌ [AuthViewModel] signInWithGoogle failed: \(error.localizedDescription)")
          self.isLoading = false
          self.errorMessage = error.localizedDescription
        }
      }
    }

    func handle(url: URL) {
      print("👤 [AuthViewModel] handle(url) called: \(url.absoluteString)")
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.manager.handle(url)
          await MainActor.run {
            print("👤 [AuthViewModel] manager.handle(url) succeeeded.")
            self.sessionToken = self.manager.sessionToken
            self.isLoading = false
          }
        } catch {
          await MainActor.run {
            print("❌ [AuthViewModel] handle(url) failed: \(error.localizedDescription)")
            // If error is "Example: user cancelled", we should stop loading
            self.isLoading = false
            self.errorMessage = "Login callback failed: \(error.localizedDescription)"
          }
        }
      }
    }

    func signOut() {
      manager.signOut()
      sessionToken = nil
    }
  }
#endif

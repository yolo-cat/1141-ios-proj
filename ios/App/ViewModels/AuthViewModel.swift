/// 2025-12-13: 改用 @Observable 並改成 async supabase 呼叫。
#if canImport(Foundation)
import Foundation
import Observation

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

    func signOut() {
        manager.signOut()
        sessionToken = nil
    }
}
#endif

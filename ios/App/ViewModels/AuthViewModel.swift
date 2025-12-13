#if canImport(Foundation)
import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var statusMessage: String?
    @Published var sessionToken: String?

    private let manager: SupabaseManaging

    init(manager: SupabaseManaging = SupabaseManager.shared) {
        self.manager = manager
        self.sessionToken = manager.sessionToken
    }

    func signIn() {
        errorMessage = nil
        statusMessage = nil
        isLoading = true
        manager.signIn(email: email, password: password) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success:
                    self.sessionToken = self.manager.sessionToken
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signUp() {
        errorMessage = nil
        statusMessage = nil
        isLoading = true
        manager.signUp(email: email, password: password) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success:
                    self.statusMessage = "Sign up succeeded. Please sign in after verification."
                case .failure(let error):
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

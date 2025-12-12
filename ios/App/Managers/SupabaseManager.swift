#if canImport(Foundation)
import Foundation

protocol SupabaseManaging {
    var sessionToken: String? { get }
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut()
    func subscribeToReadings(onInsert: @escaping (Reading) -> Void)
    func unsubscribeFromReadings()
    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void)
}

final class SupabaseManager: SupabaseManaging {
    static let shared = SupabaseManager()

    private(set) var sessionToken: String?
    private var insertHandler: ((Reading) -> Void)?

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Placeholder for real supabase-swift integration; replace with client.auth.signIn
        DispatchQueue.main.async { [weak self] in
            // DEV-STUB: replace with supabase-swift auth session token.
            self?.sessionToken = UUID().uuidString
            completion(.success(()))
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Placeholder for real supabase-swift integration; replace with client.auth.signUp
        DispatchQueue.main.async { completion(.success(())) }
    }

    func signOut() {
        sessionToken = nil
        insertHandler = nil
    }

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {
        insertHandler = onInsert
        // Real implementation: client.realtime.channel("readings").on(.insert) { payload in ... }
    }

    func unsubscribeFromReadings() {
        insertHandler = nil
        // Real implementation: channel.unsubscribe()
    }

    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
        // Placeholder: return empty list. Replace with supabase.from("readings").select().limit(limit)
        DispatchQueue.main.async { completion(.success([])) }
    }

    // Helper to feed demo data during previews/tests without network.
    func simulateInsert(reading: Reading) {
        insertHandler?(reading)
    }
}
#endif

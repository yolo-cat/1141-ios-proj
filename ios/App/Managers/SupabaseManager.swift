#if canImport(Foundation)
import Foundation

/// Protocol defining the contract for Supabase authentication and data operations.
protocol SupabaseManaging {
    /// The current session token, or `nil` if not signed in.
    ///
    /// - Note: This value may change after sign-in or sign-out operations.
    var sessionToken: String? { get }

    /// Signs in a user with the given email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: Completion handler called on the main thread with `.success` on successful sign-in, or `.failure` with an error on failure.
    /// - Note: The session token is updated on success.
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Signs up a new user with the given email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: Completion handler called on the main thread with `.success` on successful sign-up, or `.failure` with an error on failure.
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Signs out the current user and clears any session state.
    ///
    /// - Note: This method is synchronous and resets the session token and any active subscriptions.
    func signOut()

    /// Subscribes to real-time reading insert events.
    ///
    /// - Parameter onInsert: Callback invoked on the main thread whenever a new `Reading` is inserted.
    /// - Note: Only one subscription is active at a time; calling this again replaces the previous handler.
    func subscribeToReadings(onInsert: @escaping (Reading) -> Void)

    /// Unsubscribes from real-time reading insert events.
    ///
    /// - Note: After calling this, no further `onInsert` callbacks will be invoked.
    func unsubscribeFromReadings()

    /// Fetches a list of historical readings, limited to the specified number.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of readings to fetch.
    ///   - completion: Completion handler called on the main thread with `.success` and the readings array, or `.failure` with an error.
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
        unsubscribeFromReadings()
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

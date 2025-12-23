/*
 * File: SupabaseManager.swift
 * Purpose: Handles all backend interactions including Auth, Database, and Realtime syncing.
 * Architecture: Singleton implementing SupabaseManaging. Uses async/await and RealtimeV2.
 * AI Context: Central data gateway. Always use async APIs over legacy completion handlers.
 */
#if canImport(Foundation)
  import Foundation
  import Supabase

  protocol SupabaseManaging {
    var sessionToken: String? { get }

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func fetchHistory(limit: Int) async throws -> [Reading]
    func signOut()

    // Legacy support
    func signIn(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void)

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void)
    func unsubscribeFromReadings()
    func signInWithOAuth(provider: Auth.Provider, redirectTo: String?) async throws
    func handle(_ url: URL) async throws

    // Identity Linking
    func linkIdentity(provider: Auth.Provider) async throws
    func userIdentities() async throws -> [UserIdentity]
    func currentUserEmail() async throws -> String?
  }

  @MainActor
  final class SupabaseManager: SupabaseManaging {
    static let shared = SupabaseManager()
    static let defaultRedirectURL = "ZZT.ios://auth/callback"

    private(set) var sessionToken: String?
    private let supabase: SupabaseClient
    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTask: Task<Void, Never>?

    private struct ReadingRow: Codable {
      let id: Int64
      let createdAt: Date
      let deviceId: String
      let temperature: Float
      let humidity: Float

      enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case deviceId = "device_id"
        case temperature, humidity
      }

      var model: Reading {
        Reading(
          id: id, createdAt: createdAt, deviceId: deviceId, temperature: temperature,
          humidity: humidity)
      }
    }

    private static var supabaseDecoder: JSONDecoder {
      let decoder = JSONDecoder()
      // Supabase returns dates with fractional seconds (e.g., "2024-01-01T12:00:00.123456+00:00")
      // We need a custom formatter that handles this.
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let date = formatter.date(from: dateString) {
          return date
        }
        // Fallback for dates without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
          return date
        }
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "Cannot decode date: \(dateString)")
      }
      return decoder
    }

    init() {
      self.supabase = SupabaseManager.makeClient()

      // Listen to Auth State Changes
      self.realtimeTask = Task { [weak self] in
        guard let self else { return }
        for await state in self.supabase.auth.authStateChanges {

          switch state.event {
          case .initialSession, .signedIn, .tokenRefreshed:
            if let accessToken = state.session?.accessToken {
              print("🔄 [SupabaseManager] Auth State Change: \(state.event). Updating token.")
              await MainActor.run { self.sessionToken = accessToken }
            }
          case .signedOut:
            print("🔄 [SupabaseManager] Auth State Change: SignedOut. Clearing token.")
            await MainActor.run { self.sessionToken = nil }
          default: break
          }
        }
      }
    }

    // MARK: - Async APIs

    func signIn(email: String, password: String) async throws {
      let session = try await supabase.auth.signIn(email: email, password: password)
      sessionToken = session.accessToken
    }

    func signUp(email: String, password: String) async throws {
      _ = try await supabase.auth.signUp(email: email, password: password)
    }

    func signInWithOAuth(provider: Auth.Provider, redirectTo: String?) async throws {
      print(
        "🚀 [SupabaseManager] signInWithOAuth called. Provider: \(provider), RedirectTo: \(redirectTo ?? "nil")"
      )
      let url = redirectTo.flatMap { URL(string: $0) }
      try await supabase.auth.signInWithOAuth(provider: provider, redirectTo: url)
      print("✅ [SupabaseManager] signInWithOAuth executed/returned.")

      // If ASWebAuthenticationSession handled the flow, session might already be set.
      if let session = try? await supabase.auth.session {
        print(
          "✅ [SupabaseManager] Session found after signInWithOAuth. Token length: \(session.accessToken.count)"
        )
        sessionToken = session.accessToken
      } else {
        print(
          "ℹ️ [SupabaseManager] No session immediately after signInWithOAuth. Waiting for handle(url) if using custom scheme."
        )
      }
    }

    func handle(_ url: URL) async throws {
      print("🔗 [SupabaseManager] handle(url) called with: \(url.absoluteString)")
      await supabase.handle(url)

      // Update local session token after successful handling
      if let session = try? await supabase.auth.session {
        print(
          "✅ [SupabaseManager] Session retrieved successfully after handle(url). Token length: \(session.accessToken.count)"
        )
        sessionToken = session.accessToken
      } else {
        print("⚠️ [SupabaseManager] No session found after handle(url).")
      }
    }

    // MARK: - Identity Linking

    func linkIdentity(provider: Auth.Provider) async throws {
      try await supabase.auth.linkIdentity(provider: provider)
    }

    func userIdentities() async throws -> [UserIdentity] {
      return try await supabase.auth.userIdentities()
    }

    func currentUserEmail() async throws -> String? {
      let user = try await supabase.auth.user()
      return user.email
    }

    func fetchHistory(limit: Int) async throws -> [Reading] {
      let response =
        try await supabase
        .from("readings")
        .select()
        .order("created_at", ascending: false)
        .limit(limit)
        .execute()

      let rows = try SupabaseManager.supabaseDecoder.decode([ReadingRow].self, from: response.data)

      // return ascending by created_at for chart
      return rows.sorted { $0.createdAt < $1.createdAt }.map(\.model)
    }

    func signOut() {
      realtimeTask?.cancel()
      Task {
        try? await supabase.auth.signOut()
      }
      sessionToken = nil
      realtimeChannel = nil
      realtimeTask = nil
    }

    // MARK: - Legacy completion adapters

    func signIn(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {
      Task {
        do {
          try await signIn(email: email, password: password)
          await MainActor.run { completion(.success(())) }
        } catch {
          await MainActor.run { completion(.failure(error)) }
        }
      }
    }

    func signUp(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {
      Task {
        do {
          try await signUp(email: email, password: password)
          await MainActor.run { completion(.success(())) }
        } catch {
          await MainActor.run { completion(.failure(error)) }
        }
      }
    }

    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
      Task {
        do {
          let readings = try await fetchHistory(limit: limit)
          await MainActor.run { completion(.success(readings)) }
        } catch {
          await MainActor.run { completion(.failure(error)) }
        }
      }
    }

    // MARK: - Realtime

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {
      realtimeTask?.cancel()
      let channel = supabase.realtimeV2.channel("public:readings")
      realtimeChannel = channel

      realtimeTask = Task.detached { [weak channel] in
        guard let channel else { return }
        for await insertion in channel.postgresChange(InsertAction.self, table: "readings") {
          do {
            let row = try insertion.decodeRecord(
              as: ReadingRow.self, decoder: SupabaseManager.supabaseDecoder)
            await MainActor.run { onInsert(row.model) }
          } catch {
            print("Decoding error: \(error)")
            continue
          }
        }
      }

      Task {
        try? await channel.subscribe()
      }
    }

    func unsubscribeFromReadings() {
      realtimeTask?.cancel()
      realtimeTask = nil
      Task {
        if let channel = realtimeChannel {
          await channel.unsubscribe()
        }
      }
      realtimeChannel = nil
    }

    // MARK: - Client factory

    private static func makeClient() -> SupabaseClient {
      let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
      let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String

      guard let urlString = urlString, let key = key, !key.isEmpty, let url = URL(string: urlString)
      else {
        fatalError("Missing or invalid SUPABASE_URL or SUPABASE_KEY in Info.plist")
      }

      guard let host = url.host, !host.isEmpty else {
        fatalError("Invalid SUPABASE_URL: host is missing or empty")
      }

      // Define a custom URL scheme for OAuth callbacks
      // This should match the URL scheme configured in Info.plist (CFBundleURLSchemes)
      // Format: BundleID://auth/callback
      let redirectURL = URL(string: SupabaseManager.defaultRedirectURL)

      return SupabaseClient(
        supabaseURL: url,
        supabaseKey: key,
        options: .init(
          auth: .init(redirectToURL: redirectURL)
        )
      )
    }
  }
#endif

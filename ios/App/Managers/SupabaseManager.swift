/// 2025-12-13: 修正 supabase-swift API 呼叫錯誤（session、order、execute、decode）。
#if canImport(Foundation)
import Foundation
import Supabase

/// Protocol defining the contract for Supabase authentication and data operations.
protocol SupabaseManaging {
    var sessionToken: String? { get }

    // Async-first APIs
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func fetchHistory(limit: Int) async throws -> [Reading]
    func signOut()

    // Legacy completion-based adapters
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void)

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void)
    func unsubscribeFromReadings()
}

final class SupabaseManager: SupabaseManaging {
    static let shared = SupabaseManager()

    private(set) var sessionToken: String?
    private let supabase: SupabaseClient
    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTask: Task<Void, Never>?

    private struct ReadingRow: Codable {
        let id: Int64
        let created_at: Date
        let device_id: String
        let temperature: Float
        let humidity: Float

        var model: Reading {
            Reading(id: id, createdAt: created_at, deviceId: device_id, temperature: temperature, humidity: humidity)
        }
    }

    init() {
        self.supabase = SupabaseManager.makeClient()
    }

    // MARK: - Async APIs

    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        sessionToken = session.accessToken
    }

    func signUp(email: String, password: String) async throws {
        _ = try await supabase.auth.signUp(email: email, password: password)
    }

    func fetchHistory(limit: Int) async throws -> [Reading] {
        let rows: [ReadingRow] = try await supabase.database
            .from("readings")
            .select()
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        // return ascending by created_at for chart
        return rows.sorted { $0.created_at < $1.created_at }.map(\.model)
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

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await signIn(email: email, password: password)
                await MainActor.run { completion(.success(())) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
                    let row = try insertion.decodeRecord(as: ReadingRow.self, decoder: JSONDecoder())
                    await MainActor.run { onInsert(row.model) }
                } catch {
                    continue
                }
            }
        }

        Task {
            await channel.subscribe()
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
        let env = ProcessInfo.processInfo.environment
        guard
            let urlString = env["SUPABASE_URL"],
            let key = env["SUPABASE_KEY"],
            let url = URL(string: urlString),
            !key.isEmpty
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_KEY in environment.")
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
#endif

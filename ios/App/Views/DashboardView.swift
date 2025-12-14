/// 2025-12-14: 新增 Dashboard #Preview 預覽。
#if canImport(SwiftUI)
import SwiftUI
import Observation

struct DashboardView: View {
    @Bindable var viewModel: SensorViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let reading = viewModel.currentReading {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device: \(reading.deviceId)")
                        .font(.headline)
                    Text("Temperature: \(reading.temperature, specifier: "%.1f") °C")
                        .font(.title2)
                    Text("Humidity: \(reading.humidity, specifier: "%.1f") %")
                        .font(.title2)
                    Text("Time: \(formatted(date: reading.createdAt))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            } else {
                Text("Waiting for realtime readings...")
                    .foregroundColor(.secondary)
            }

            Button(viewModel.isSubscribed ? "Stop Realtime" : "Start Realtime") {
                viewModel.isSubscribed ? viewModel.stopListening() : viewModel.startListening()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .onAppear { viewModel.startListening() }
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DashboardView(viewModel: .preview)
}

private extension SensorViewModel {
    static var preview: SensorViewModel {
        let manager = MockSupabaseManager()
        let viewModel = SensorViewModel(manager: manager)
        viewModel.currentReading = Reading(
            id: 1,
            createdAt: Date(),
            deviceId: "tea_room_01",
            temperature: 22.5,
            humidity: 58.3
        )
        viewModel.isSubscribed = true
        return viewModel
    }
}

private final class MockSupabaseManager: SupabaseManaging {
    var sessionToken: String? = nil

    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func fetchHistory(limit: Int) async throws -> [Reading] { [] }
    func signOut() {}

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
        completion(.success([]))
    }

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {}
    func unsubscribeFromReadings() {}
}
#endif

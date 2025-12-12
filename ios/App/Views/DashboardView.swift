#if canImport(SwiftUI)
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: SensorViewModel

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
#endif

#if canImport(Foundation)
import Foundation

struct Reading: Identifiable, Equatable {
    let id: Int64
    let createdAt: Date
    let deviceId: String
    let temperature: Float
    let humidity: Float

    static let placeholder = Reading(
        id: 0,
        createdAt: Date(),
        deviceId: "demo",
        temperature: 0,
        humidity: 0
    )
}
#endif

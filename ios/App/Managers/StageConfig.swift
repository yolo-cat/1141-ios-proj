#if canImport(Foundation)
import Foundation

enum StageConfig {
    static let temperatureThreshold: Float = 30
    static let humidityThreshold: Float = 70
    static let historyLimit: Int = 100
    static let alertCooldown: TimeInterval = 30
}
#endif

/// 2025-12-13: 將 historyLimit 調整為 288 並新增版本註釋。
#if canImport(Foundation)
import Foundation

enum StageConfig {
    static let temperatureThreshold: Float = 30
    static let humidityThreshold: Float = 70
    static let historyLimit: Int = 288
    static let alertCooldown: TimeInterval = 30
}
#endif

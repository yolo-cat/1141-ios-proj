import Foundation
import XCTest

/// Lightweight specification tests for Stage-1 behaviors.
/// These doubles enable TDD before real ViewModel/Service implementations exist.

private struct Reading: Equatable {
    let id: Int
    let createdAt: Date
    let deviceId: String
    let temperature: Float
    let humidity: Float
}

private struct Thresholds {
    let temperature: Float
    let humidity: Float
}

private final class SensorViewModelSpecDouble {
    var currentReading: Reading?
    var history: [Reading] = []
    var alertRaised = false
    var thresholds = Thresholds(temperature: 30.0, humidity: 70.0)

    func handleRealtimeInsert(_ reading: Reading) {
        let temperatureThreshold = thresholds.temperature
        let humidityThreshold = thresholds.humidity
        currentReading = reading
        alertRaised = reading.temperature > temperatureThreshold || reading.humidity > humidityThreshold
    }

    func fetchHistory(limit: Int) -> [Reading] {
        Array(history
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit))
    }
}

private enum StubAuthError: Error { case invalid }

private final class StubAuthService {
    var storedSession: String?
    var shouldFail = false

    func signIn(email: String, password: String) throws -> String {
        if shouldFail { throw StubAuthError.invalid }
        let session = "session-\(email)"
        storedSession = session
        return session
    }

    func signOut() {
        storedSession = nil
    }
}

final class Stage1SpecTests: XCTestCase {
    func testRealtimeInsertUpdatesCurrentReading() {
        let vm = SensorViewModelSpecDouble()
        let sample = Reading(id: 1,
                             createdAt: Date(),
                             deviceId: "tea_room_01",
                             temperature: 25.3,
                             humidity: 55.0)

        vm.handleRealtimeInsert(sample)

        XCTAssertEqual(vm.currentReading, sample)
        XCTAssertFalse(vm.alertRaised)
    }

    func testThresholdTriggersAlertFlag() {
        let vm = SensorViewModelSpecDouble()
        let hot = Reading(id: 2,
                          createdAt: Date(),
                          deviceId: "tea_room_01",
                          temperature: 31.0,
                          humidity: 55.0)

        vm.handleRealtimeInsert(hot)
        XCTAssertTrue(vm.alertRaised)
    }

    func testHistoryIsSortedAndTruncated() {
        let vm = SensorViewModelSpecDouble()
        let now = Date()
        let intervalStep: TimeInterval = 5.0
        vm.history = (0..<5).map { idx in
            Reading(id: idx,
                    createdAt: now.addingTimeInterval(Double(idx) * intervalStep),
                    deviceId: "tea_room_01",
                    temperature: 20 + Float(idx),
                    humidity: 50 + Float(idx))
        }

        let result = vm.fetchHistory(limit: 3)
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result[0].createdAt > result[1].createdAt)
        XCTAssertTrue(result[1].createdAt > result[2].createdAt)
    }

    func testSignInStoresSessionAndSignOutClearsIt() throws {
        let auth = StubAuthService()
        let session = try auth.signIn(email: "user@test.com", password: "password")

        XCTAssertEqual(session, "session-user@test.com")
        XCTAssertNotNil(auth.storedSession)

        auth.signOut()
        XCTAssertNil(auth.storedSession)
    }

    func testSignInErrorPropagates() {
        let auth = StubAuthService()
        auth.shouldFail = true

        XCTAssertThrowsError(try auth.signIn(email: "user@test.com", password: "password"))
    }
}

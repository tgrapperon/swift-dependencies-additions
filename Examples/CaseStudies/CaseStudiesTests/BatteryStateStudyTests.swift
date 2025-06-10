import Dependencies
import DependenciesAdditionsBasics
import XCTest

@testable import CaseStudies

@MainActor
final class BatteryStatusStudyTests: XCTestCase {
  func testBatteryStatusStudy() async throws {
    @Dependency(\.notificationCenter) var notificationCenter

    @MainActor
    final class Values {
      var batteryState: UIDevice.BatteryState = .unplugged
      var batteryLevel: Float = 0.7
    }
    let values = Values()
    try await withDependencies {
      $0.notificationCenter = .default
      $0.device.$isBatteryMonitoringEnabled = .constant(true)
      $0.device.$batteryLevel = { @Sendable in values.batteryLevel }
      $0.device.$batteryState = { @Sendable in values.batteryState }
    } operation: {
      let model = BatteryStatusStudy()

      model.onAppear()
      try await Task.sleep(for: .milliseconds(10))

      XCTAssertEqual(model.batteryState, .unplugged)
      XCTAssertEqual(model.batteryLevel, 0.7)

      values.batteryLevel = 0.9
      notificationCenter.post(name: UIDevice.batteryLevelDidChangeNotification)
      try await Task.sleep(for: .milliseconds(10))

      XCTAssertEqual(model.batteryLevel, 0.9)
      XCTAssertEqual(model.batteryState, .unplugged)

      values.batteryState = .charging
      notificationCenter.post(name: UIDevice.batteryStateDidChangeNotification)
      try await Task.sleep(for: .milliseconds(10))

      XCTAssertEqual(model.batteryLevel, 0.9)
      XCTAssertEqual(model.batteryState, .charging)

      values.batteryLevel = 0.2
      model.batteryLevelNotification.testing.post(0)
      try await Task.sleep(for: .milliseconds(10))

      XCTAssertEqual(model.batteryLevel, 0.2)
      XCTAssertEqual(model.batteryState, .charging)
    }
  }
}

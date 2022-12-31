import Dependencies
import DeviceDependency
import XCTest

#if os(iOS) || os(tvOS)
  @MainActor
  final class DevieDepedencyTests: XCTestCase {
    @Dependency(\.device) var device

    func testBundleInfo() {
      withDependencyValues {
        $0.device.$batteryLevel = 42
      } operation: {
        XCTAssertEqual(device.batteryLevel, 42)
      }
    }

    func testFailingTestBundleInfo() {
      XCTExpectFailure {
        XCTAssertEqual(device.systemName, "")
      }
    }
  }
#endif

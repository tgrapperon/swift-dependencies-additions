import Dependencies
import DeviceDependency
import XCTest

#if os(iOS) || os(tvOS)
  @MainActor
  final class DevieDepedencyTests: XCTestCase {
    @Dependency(\.device) var device

    func testBundleInfo() {
      DependencyValues.withValues {
        $0.device.$batteryLevel = 42
      } operation: {
        XCTAssertEqual(device.batteryLevel, 42)
      }
    }

    func testFailingTestBundleInfo() {
      XCTExpectFailure {
        DependencyValues.withTestValues {
          XCTAssertEqual(device.systemName, "")
        }
      }
    }
  }
#endif

import Dependencies
import DeviceDependency
import XCTest

#if canImport(DeviceCheck)
  final class DeviceCheckDependencyTests: XCTestCase {
    @Dependency(\.deviceCheckDevice) var device

    #if DEBUG
    @available(iOS 11, tvOS 11, macOS 10.15, watchOS 9.0, *)
    func testUnimplementedIsSupported() {
      XCTExpectFailure {
        let _ = device.isSupported
      }
    }
    #endif

    @available(iOS 11, tvOS 11, macOS 10.15, watchOS 9.0, *)
    func testUnimplementedGenerateToken() async throws {
      // Can't test for async failures, or can we?
      //      XCTExpectFailure {
      //        let _ = try await device.generateToken()
      //      }
    }
  }
#endif

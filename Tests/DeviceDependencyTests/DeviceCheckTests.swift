import Dependencies
import DeviceDependency
import XCTest

#if canImport(DeviceCheck)
  final class DeviceCheckDependencyTests: XCTestCase {
    @Dependency(\.deviceCheckDevice) var device

    @available(iOS 11, tvOS 11, macOS 10.15, watchOS 9.0, *)
    func testUnimplementedIsSupported() {
      XCTExpectFailure {
        let _ = device.isSupported
      }
    }

    @available(iOS 11, tvOS 11, macOS 10.15, watchOS 9.0, *)
    func testUnimplementedGenerateToken() async throws {
      //      XCTExpectFailure {
      //        let _ = try await device.generateToken()
      //      }
    }
  }
#endif

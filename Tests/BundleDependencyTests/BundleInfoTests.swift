import BundleDependency
import Dependencies
import XCTest

final class BundleInfoTests: XCTestCase {
  @Dependency(\.bundleInfo) var bundleInfo

  func testBundleInfo() {
    withDependencyValues {
      $0.bundleInfo = .init(
        bundleIdentifier: "com.company.app",
        name: "Name",
        displayName: "DisplayName",
        spokenName: "SpokenName",
        shortVersion: "1.7",
        version: "12345"
      )
    } operation: {
      XCTAssertEqual(bundleInfo.bundleIdentifier, "com.company.app")
      XCTAssertEqual(bundleInfo.name, "Name")
      XCTAssertEqual(bundleInfo.displayName, "DisplayName")
      XCTAssertEqual(bundleInfo.spokenName, "SpokenName")
      XCTAssertEqual(bundleInfo.shortVersion, "1.7")
      XCTAssertEqual(bundleInfo.version, "12345")
    }
  }

  func testFailingTestBundleInfo() {
    XCTExpectFailure {
      XCTAssertEqual(bundleInfo.bundleIdentifier, "")
    }
  }
}

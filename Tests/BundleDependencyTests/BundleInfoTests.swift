import BundleDependency
import Dependencies
import XCTest

@MainActor
final class BundleInfoTests: XCTestCase {
  @Dependency(\.bundleInfo) var bundleInfo

  func testBundleInfo() {
    withDependencies {
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

  #if DEBUG
    func testFailingTestBundleInfo_bundleIdentifier() {
      XCTExpectFailure {
        _ = bundleInfo.bundleIdentifier
      }
    }
    func testFailingTestBundleInfo_name() {
      XCTExpectFailure {
        _ = bundleInfo.name
      }
    }
    func testFailingTestBundleInfo_displayName() {
      XCTExpectFailure {
        _ = bundleInfo.displayName
      }
    }
    func testFailingTestBundleInfo_spokenName() {
      XCTExpectFailure {
        _ = bundleInfo.spokenName
      }
    }
    func testFailingTestBundleInfo_shortVersion() {
      XCTExpectFailure {
        _ = bundleInfo.shortVersion
      }
    }
    func testFailingTestBundleInfo_version() {
      XCTExpectFailure {
        _ = bundleInfo.version
      }
    }
  #endif
}

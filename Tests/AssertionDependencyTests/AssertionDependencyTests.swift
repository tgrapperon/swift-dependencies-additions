import AssertionDependency
import Dependencies
import XCTest

final class AssertionDependencyTests: XCTestCase {
  @Dependency(\.assert) var assert
  @Dependency(\.assertionFailure) var assertionFailure

  func testAssert() {
    assert(true, "Test assertion does not generate failure for true condition")

    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
      XCTExpectFailure {
        assert(false, "Test assertion generates failure for false condition")
      }
    #endif

    withDependencies {
      $0.context = .live
    } operation: {
      assert(true, "Live assertion does not assert for true condition")
    }
  }

  func testAssertionFailure() {
      #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        XCTExpectFailure {
          assertionFailure("Test assertionFailure generates failure")
        }
      #endif
  }
}

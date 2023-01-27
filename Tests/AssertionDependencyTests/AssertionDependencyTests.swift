import AssertionDependency
import Dependencies
import XCTest

final class AssertionDependencyTests: XCTestCase {
  @Dependency(\.assert) var assert
  @Dependency(\.assertionFailure) var assertionFailure

  func testAssert() {
    // Test assertion does not generate failure for true condition
    assert(true)

    XCTExpectFailure("Test assertion generates failure for false condition") {
      assert(false)
    }

    withDependencies {
      $0.context = .live
    } operation: {
      // Live assertion does not assert for true condition
      assert(true)
    }
  }

  func testAssertionFailure() {
    XCTExpectFailure("Test assertionFailure generates failure") {
      assertionFailure("test")
    }
  }
}

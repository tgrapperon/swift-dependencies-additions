import XCTest
import LoggerDependency
import Dependencies

final class LoggerDependencyTests: XCTestCase {
  @Dependency(\.logger) var logger
  func testFailingTestLogger() {
    XCTExpectFailure {
      DependencyValues.withTestValues {
        logger.log("TestValue")
      }
    }
  }
}

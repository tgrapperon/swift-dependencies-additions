import XCTest
import LoggerDependency
import Dependencies
import BundleInfo

final class LoggerDependencyTests: XCTestCase {
  @Dependency(\.logger) var logger
  func testFailingTestLogger() {
    XCTExpectFailure {
      DependencyValues.withTestValues {
        logger.log("TestValue")
      }
    }
  }
  
  func testLoggerCategory() {
    @Dependency(\.logger["Logger.Dependency.Testing"]) var logger;
    logger.log(level: .info, "This is a test info message in some logger category")
  }
}

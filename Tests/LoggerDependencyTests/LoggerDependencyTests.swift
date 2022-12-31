import BundleInfoDependency
import Dependencies
import LoggerDependency
import XCTest

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
final class LoggerDependencyTests: XCTestCase {
  @Dependency(\.logger) var logger
  func testFailingTestLogger() {
    XCTExpectFailure {
      logger.log("TestValue")
    }
  }

  func testLoggerCategory() {
    @Dependency(\.logger["Logger.Dependency.Testing"]) var logger;
    withDependencyValues {
      $0.context = .live
    } operation: {
      logger.log(level: .info, "This is a test info message in some logger category")
    }
  }
}

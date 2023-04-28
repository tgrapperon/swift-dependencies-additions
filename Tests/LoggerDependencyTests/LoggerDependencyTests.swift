#if canImport(OSLog)
  import BundleDependency
  import Dependencies
import DependenciesAdditionsBasics
  import LoggerDependency
  import XCTest
  import OSLog

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  final class LoggerDependencyTests: XCTestCase {
    @Dependency(\.logger) var logger

    func testNotFailingTestLogger() {
      logger.log("TestValue")
    }

    func testLoggerCategory() {
      @Dependency(\.logger["Logger.Dependency.Testing"]) var logger: Logger

      withDependencies {
        $0.context = .live
      } operation: {
        logger.log(level: .info, "This is a test info message in some logger category")
      }
    }
  }
#endif

#if canImport(OSLog)
  import BundleDependency
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import LoggerDependency
  import XCTest

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  final class LoggerDependencyTests: XCTestCase {
    @Dependency(\.logger) var logger

    #if (os(iOS) || os(macOS) || os(tvOS) || os(watchOS)) && DEBUG
      func testFailingTestLogger() {
        XCTExpectFailure {
          logger.log("TestValue")
        }
      }
    #endif

    func testLoggerCategory() {
      @Dependency(\.logger["Logger.Dependency.Testing"]) var logger
      let _ = __dummySeparator__
      withDependencies {
        $0.context = .live
      } operation: {
        logger.log(level: .info, "This is a test info message in some logger category")
      }
    }
  }
#endif

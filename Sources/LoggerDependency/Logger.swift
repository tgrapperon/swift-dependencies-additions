import Dependencies
import Foundation
@preconcurrency import OSLog

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension DependencyValues {
  public var logger: Logger {
    get { self[Logger.self] }
    set { self[Logger.self] = newValue }
  }
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension Logger: DependencyKey {
  public static var liveValue: Logger { Logger() }
  public static var testValue: Logger {
    XCTFail(#"Unimplemented: @Dependency(\.logger)"#)
    return Logger()
  }
}

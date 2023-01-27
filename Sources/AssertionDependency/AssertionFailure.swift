import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  /// A ``AssertionFailureAction`` that will perform an action when reached.
  ///
  /// Defaults to calling the standard Swift `assertionFailure` function in live context and
  /// producing a test failure in tests.
  public var assertionFailure: AssertionFailureAction {
    get { self[AssertionFailureAction.self] }
    set { self[AssertionFailureAction.self] = newValue }
  }
}

extension AssertionFailureAction: DependencyKey {
  public static let liveValue = AssertionFailureAction {
    Swift.assertionFailure($0(), file: $1, line: $2)
  }

  public static let previewValue = AssertionFailureAction { _, _, _ in
    // no-op
  }

  public static let testValue = AssertionFailureAction { message, file, line in
    XCTFail(message(), file: file, line: line)
  }
}


public struct AssertionFailureAction: Sendable {
  public let action: @Sendable (@autoclosure () -> String, StaticString, UInt) -> ()

  public init(action: @Sendable @escaping (() -> String, StaticString, UInt) -> Void) {
    self.action = action
  }

  @inline(__always)
  public func callAsFunction(
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    action(message(), file, line)
  }
}

import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  /// A ``AssertAction`` that will perform an action when the condition evaluates to `false`.
  ///
  /// Defaults to calling the standard Swift `assert` function in live context and producing a test
  /// failure in tests.
  public var assert: AssertAction {
    get { self[AssertAction.self] }
    set { self[AssertAction.self] = newValue }
  }
}

extension AssertAction: DependencyKey {
  public static let liveValue = AssertAction {
    Swift.assert($0(), $1(), file: $2, line: $3)
  }

  public static let previewValue = AssertAction { _, _, _, _ in
    // no-op
  }

  public static let testValue = AssertAction { condition, message, file, line in
    if !condition() {
      XCTFail(message(), file: file, line: line)
    }
  }
}

public struct AssertAction: Sendable {
  public let action: @Sendable (@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> ()

  public init(action: @Sendable @escaping (() -> Bool, () -> String, StaticString, UInt) -> Void) {
    self.action = action
  }

  @inline(__always)
  public func callAsFunction(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    action(condition(), message(), file, line)
  }
}

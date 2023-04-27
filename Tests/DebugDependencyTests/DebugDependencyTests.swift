import DebugDependency
import Dependencies
import XCTest

@available(iOS 14.0, *)
final class DebugDependencyTests: XCTestCase {
  @Dependency(\.debug) var debug
  func testStack() {
    self.debug.stackDepth()
  }
}

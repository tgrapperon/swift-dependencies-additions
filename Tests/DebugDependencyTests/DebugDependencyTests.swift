import DebugDependency
import Dependencies
import XCTest

@available(iOS 14.0, *)
final class DebugDependencyTests: XCTestCase {
  @Dependency(\.debug) var debug
  func testStack() {
    withDependencies {
      $0.logger = .liveValue
    } operation: {
      self.debug.stackDepth()
      self.debug.stackDepth()
      self.debug.stackDepth(label: "testt")
      let x = 1000
      self.debug.stackDepth()
      self.debug.stackDepth()
    }

    
//      withDependencies { $0.logger = .liveValue } operation: {
//        @Dependency(\.logger["Logger.Dependency.Testing"].stackDepth) var stackDepth
//        stackDepth()
//      }
  }
}

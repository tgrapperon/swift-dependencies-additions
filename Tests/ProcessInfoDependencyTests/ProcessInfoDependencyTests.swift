import XCTest
import ProcessInfoDependency
import Dependencies


final class ProcessInfoDependencyTests: XCTestCase {
  @Dependency(\.processInfo) var processInfo
  func testFailingProcessInfo() {
    XCTExpectFailure {
      let _ = processInfo.processorCount

    }
  }
  
  func testProcessInfoConfiguration() {
    withDependencyValues {
      $0.processInfo.$processorCount = 128
    } operation: {
      XCTAssertEqual(processInfo.processorCount, 128)
    }
  }
}

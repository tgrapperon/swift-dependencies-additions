import Dependencies
import DependenciesAdditionsBasics
import XCTest

@MainActor
final class DependenciesAdditionsBasicsTests: XCTestCase {
  //  struct Value {
  //    @PP var lp: Int
  //    @ROLP var rolp: Int
  //    @MALP var malp: Int
  //    @ROMALP var romalp: Int
  //
  //    init() {
  //      self._lp = .init(({ 4 }, { _ in () }))
  //      self._rolp = .init({ 4 })
  //      self._malp = .init(({ 4 }, { _ in () }))
  //      self._romalp = .init({ 4 })
  //    }
  //  }
  //
  //  @MainActor
  //  func testFailingLazyProxyProjectedValueWriting() {
  //    var value = Value()
  //
  //    withDependencies {
  //      $0.context = .live
  //    } operation: {
  //      XCTExpectFailure {
  //        value.$lp.value = 5
  //      }
  //    }
  //  }
  //
  //  @MainActor
  //  func testFailingReadOnlyLazyProxyProjectedValueWriting() {
  //    var value = Value()
  //
  //    withDependencies {
  //      $0.context = .live
  //    } operation: {
  //      XCTExpectFailure {
  //        value.$rolp.value = 5
  //      }
  //    }
  //  }
  //
  //  @MainActor
  //  func testFailingLazyMainActorProxyProjectedValueWriting() {
  //    var value = Value()
  //
  //    withDependencies {
  //      $0.context = .live
  //    } operation: {
  //      XCTExpectFailure {
  //        value.$malp.value = 5
  //      }
  //    }
  //  }
  //
  //  @MainActor
  //  func testFailingReadOnlyMainActorLazyProxyProjectedValueWriting() {
  //    var value = Value()
  //
  //    withDependencies {
  //      $0.context = .live
  //    } operation: {
  //      XCTExpectFailure {
  //        value.$romalp.value = 5
  //      }
  //    }
  //  }
}

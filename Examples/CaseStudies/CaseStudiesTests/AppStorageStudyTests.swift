import CombineSchedulers
import Dependencies
import XCTest
import _AppStorageDependency

@testable import CaseStudies

@MainActor
final class AppStorageStudyTests: XCTestCase {
  func testAppStorageStudy() async throws {

    let mainQueue = DispatchQueue.test
    try await withDependencies {
      $0.userDefaults = .ephemeral()
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    } operation: {
      @Dependency.AppStorage("number") var number: Int?
      @Dependency.AppStorage("string") var string: String?

      let model = UserDefaultsStudy()
      XCTAssertEqual(model.observedNumberValue, nil)
      XCTAssertEqual(model.observedStringValue, nil)

      await mainQueue.advance(by: .milliseconds(250))
      XCTAssertEqual(model.publishedNumber, 42)
      XCTAssertEqual(model.publishedString, nil)

      model.updateNumberButtonTapped(value: 139)
      XCTAssertEqual(model.publishedNumber, 139)
      XCTAssertEqual(number, 42)
      await mainQueue.advance(by: .milliseconds(250))
      XCTAssertEqual(number, 139)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 139)

      model.updateNumberButtonTapped(value: 44)
      XCTAssertEqual(model.publishedNumber, 44)
      XCTAssertEqual(number, 139)
      await mainQueue.advance(by: .milliseconds(250))
      XCTAssertEqual(number, 44)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 44)

      model.resetNumberButtonTapped()
      XCTAssertEqual(model.publishedNumber, 42)
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(number, nil)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 42)
    }
  }
}

import XCTest
@testable import CaseStudies
import Dependencies
import AppStorage

@MainActor
final class AppStorageStudyTests: XCTestCase {
  func testAppStorageStudy() async throws {
    try await DependencyValues.withValue(\.userDefaults, .ephemeral()) {
      @Dependency.AppStorage("number") var number: Int?
      @Dependency.AppStorage("string") var string: String?
      
      let model = AppStorageStudy()
      
      XCTAssertEqual(model.publishedNumber, 42)
      XCTAssertEqual(model.publishedString, nil)
      
      XCTAssertEqual(model.observedNumberValue, nil)
      XCTAssertEqual(model.observedStringValue, nil)

      model.userDidUpdateNumber(value: 139)
      XCTAssertEqual(model.publishedNumber, 139)
      XCTAssertEqual(number, 139)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 139)
      
      model.userDidUpdateNumber(value: 44)
      XCTAssertEqual(model.publishedNumber, 44)
      XCTAssertEqual(number, 44)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 44)
      
      model.userDidTapResetNumber()
      XCTAssertEqual(model.publishedNumber, 42)
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(number, 42)

      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      XCTAssertEqual(model.observedNumberValue, 42)
    }
  }
}

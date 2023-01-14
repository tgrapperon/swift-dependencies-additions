import Dependencies
import UserDefaultsDependency
import XCTest

// TODO: Expand this suite

final class UserDefaultsDependencyTests: XCTestCase {
  @Dependency(\.userDefaults) var userDefaults
  func testEphemeralDefaultsDate() {
    let ephemeral = UserDefaults.Dependency.ephemeral()
    let date = Date(timeIntervalSince1970: 1000)
    withDependencies {
      $0.userDefaults = ephemeral
    } operation: {
      self.userDefaults.set(date, forKey: "date")
    }
    withDependencies {
      $0.userDefaults = ephemeral
    } operation: {
      XCTAssertEqual(self.userDefaults.date(forKey: "date"), date)
    }
  }

  func testLiveUserDefaultsDate() {
    let date = Date(timeIntervalSince1970: 1000)
    UserDefaults.standard.removeObject(forKey: "date")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(date, forKey: "date")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.date(forKey: "date"), date)
    }
    UserDefaults.standard.removeObject(forKey: "date")
  }
}

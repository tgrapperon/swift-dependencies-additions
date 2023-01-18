import Dependencies
import UserDefaultsDependency
import XCTest

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

  func testLiveUserDefaultsBool() {
    let bool = true
    UserDefaults.standard.removeObject(forKey: "bool")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(bool, forKey: "bool")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.bool(forKey: "bool"), bool)
    }
    UserDefaults.standard.removeObject(forKey: "double")
  }

  func testLiveUserDefaultsData() {
    let data = "123".data(using: .utf8)!
    UserDefaults.standard.removeObject(forKey: "data")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(data, forKey: "data")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.data(forKey: "data"), data)
    }
    UserDefaults.standard.removeObject(forKey: "data")
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

  func testLiveUserDefaultsDouble() {
    let double = 123.4
    UserDefaults.standard.removeObject(forKey: "double")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(double, forKey: "double")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.double(forKey: "double"), double)
    }
    UserDefaults.standard.removeObject(forKey: "double")
  }

  func testLiveUserDefaultsInt() {
    let int = 123
    UserDefaults.standard.removeObject(forKey: "int")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(int, forKey: "int")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.integer(forKey: "int"), int)
    }
    UserDefaults.standard.removeObject(forKey: "int")
  }

  func testLiveUserDefaultsString() {
    let string = "Hello!"
    UserDefaults.standard.removeObject(forKey: "string")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(string, forKey: "string")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.string(forKey: "string"), string)
    }
    UserDefaults.standard.removeObject(forKey: "string")
  }
  #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  func testLiveUserDefaultsURL() {
    let url = URL(string: "https://github.com/tgrapperon/swift-dependencies-additions")
    UserDefaults.standard.removeObject(forKey: "url")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(url, forKey: "url")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.url(forKey: "url"), url)
    }
    UserDefaults.standard.removeObject(forKey: "url")
  }
  
  func testLiveUserDefaultsFileURL() {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("Tests")
    UserDefaults.standard.removeObject(forKey: "url")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(url, forKey: "url")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.url(forKey: "url"), url)
    }
    UserDefaults.standard.removeObject(forKey: "url")
  }
  #endif
  func testLiveUserDefaultsStringRawRepresentable() {
    enum Value: String {
      case one
      case two
    }
    let raw = Value.two
    UserDefaults.standard.removeObject(forKey: "raw")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(raw, forKey: "raw")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.rawRepresentable(forKey: "raw"), raw)
    }
    UserDefaults.standard.removeObject(forKey: "raw")
  }

  func testLiveUserDefaultsIntRawRepresentable() {
    enum Value: Int {
      case one
      case two
    }
    let raw = Value.two
    UserDefaults.standard.removeObject(forKey: "raw")
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(raw, forKey: "raw")
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.rawRepresentable(forKey: "raw"), raw)
    }
    UserDefaults.standard.removeObject(forKey: "raw")
  }

}

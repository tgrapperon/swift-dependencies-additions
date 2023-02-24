import Dependencies
import UserDefaultsDependency
import XCTest

final class UserDefaultsDependencyTests: XCTestCase {
  @Dependency(\.userDefaults) var userDefaults
  func testEphemeralDefaultsDate() {
    let ephemeral = UserDefaults.Dependency.ephemeral()
    let date = Date(timeIntervalSince1970: 1000)
    let key = #function
    withDependencies {
      $0.userDefaults = ephemeral
    } operation: {
      self.userDefaults.set(date, forKey: key)
    }
    withDependencies {
      $0.userDefaults = ephemeral
    } operation: {
      XCTAssertEqual(self.userDefaults.date(forKey: key), date)
    }
  }

  func testLiveUserDefaultsBool() {
    let bool = true
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(bool, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.bool(forKey: key), bool)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsData() {
    let data = "123".data(using: .utf8)!
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(data, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.data(forKey: key), data)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsDate() {
    let date = Date(timeIntervalSince1970: 1000)
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(date, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.date(forKey: key), date)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsDouble() {
    let double = 123.4
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(double, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.double(forKey: key), double)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsInt() {
    let int = 123
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(int, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.integer(forKey: key), int)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsString() {
    let string = "Hello!"
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(string, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.string(forKey: key), string)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }
  #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    func testLiveUserDefaultsURL() {
      let url = URL(string: "https://github.com/tgrapperon/swift-dependencies-additions")
      let key = #function
      UserDefaults.standard.removeObject(forKey: key)
      withDependencies {
        $0.userDefaults = .standard
      } operation: {
        self.userDefaults.set(url, forKey: key)
      }
      withDependencies {
        $0.userDefaults = .standard
      } operation: {
        XCTAssertEqual(self.userDefaults.url(forKey: key), url)
      }
      UserDefaults.standard.removeObject(forKey: key)
    }

    func testLiveUserDefaultsFileURL() {
      let url = FileManager.default.temporaryDirectory.appendingPathComponent("Tests")
      let key = #function
      UserDefaults.standard.removeObject(forKey: key)
      withDependencies {
        $0.userDefaults = .standard
      } operation: {
        self.userDefaults.set(url, forKey: key)
      }
      withDependencies {
        $0.userDefaults = .standard
      } operation: {
        XCTAssertEqual(self.userDefaults.url(forKey: key), url)
      }
      UserDefaults.standard.removeObject(forKey: key)
    }
  #endif
  func testLiveUserDefaultsStringRawRepresentable() {
    enum Value: String {
      case one
      case two
    }
    let raw = Value.two
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(raw, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.rawRepresentable(forKey: key), raw)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

  func testLiveUserDefaultsIntRawRepresentable() {
    enum Value: Int {
      case one
      case two
    }
    let raw = Value.two
    let key = #function
    UserDefaults.standard.removeObject(forKey: key)
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      self.userDefaults.set(raw, forKey: key)
    }
    withDependencies {
      $0.userDefaults = .standard
    } operation: {
      XCTAssertEqual(self.userDefaults.rawRepresentable(forKey: key), raw)
    }
    UserDefaults.standard.removeObject(forKey: key)
  }

}

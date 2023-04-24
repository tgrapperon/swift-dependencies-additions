import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
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
    UserDefaults.standard.removeObject(forKey: "bool")
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

  func testLiveUserDefaultsBoolValues() async throws {
    UserDefaults.standard.removeObject(forKey: "bool")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Bool?> = [nil, true, nil, false][...]
          for await bool in self.userDefaults.boolValues(forKey: "bool") {
            XCTAssertEqual(bool, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(true, forKey: "bool")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Bool?.none, forKey: "bool")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(false, forKey: "bool")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "bool")
  }

  func testLiveUserDefaultsDataValues() async throws {
    UserDefaults.standard.removeObject(forKey: "data")
    let d1 = "1".data(using: .utf8)!
    let d2 = "2".data(using: .utf8)!
    let d3 = "3".data(using: .utf8)!
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Data?> = [nil, d1, d2, d3][...]
          for await data in self.userDefaults.dataValues(forKey: "data") {
            XCTAssertEqual(data, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(d1, forKey: "data")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(d2, forKey: "data")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(d3, forKey: "data")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "data")
  }

  func testLiveUserDefaultsDoubleValues() async throws {
    UserDefaults.standard.removeObject(forKey: "double")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Double?> = [nil, 1.0, 4.0, 7.0][...]
          for await double in self.userDefaults.doubleValues(forKey: "double") {
            XCTAssertEqual(double, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1.0, forKey: "double")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4.0, forKey: "double")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7.0, forKey: "double")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "double")
  }

  func testLiveUserDefaultsStringValues() async throws {
    UserDefaults.standard.removeObject(forKey: "string")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<String?> = [nil, "a", "b", "c"][...]
          for await string in self.userDefaults.stringValues(forKey: "string") {
            XCTAssertEqual(string, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set("a", forKey: "string")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set("b", forKey: "string")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set("c", forKey: "string")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "string")
  }

  #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    func testLiveUserDefaultsURLValues() async throws {
      UserDefaults.standard.removeObject(forKey: "url")
      let url1 = URL(string: "www.github.com")!
      let url2 = URL(string: "www.apple.com")!
      let url3 = URL(string: "www.pointfree.co")!
      await withDependencies {
        $0.userDefaults = .liveValue
      } operation: {
        await withTimeout { group in
          group.addTask {
            var expectations: ArraySlice<URL?> = [nil, url1, url2, url3][...]
            for await url in self.userDefaults.urlValues(forKey: "url") {
              XCTAssertEqual(url, expectations.first)
              expectations = expectations.dropFirst()
              if expectations.isEmpty { break }
            }
          }
          group.addTask {
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
            self.userDefaults.set(url1, forKey: "url")
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
            self.userDefaults.set(url2, forKey: "url")
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
            self.userDefaults.set(url3, forKey: "url")
          }
        }
      }
      UserDefaults.standard.removeObject(forKey: "url")
    }
  #endif

  func testLiveUserDefaultsStringRawRepresentableValues() async throws {
    enum Value: String {
      case one
      case two
    }
    UserDefaults.standard.removeObject(forKey: "raw")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Value?> = [nil, .one, .two, .one][...]
          for await value in self.userDefaults.rawRepresentableValues(Value.self, forKey: "raw")
          {
            XCTAssertEqual(value, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.one, forKey: "raw")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.two, forKey: "raw")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.one, forKey: "raw")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "raw")
  }

  func testLiveUserDefaultsIntRawRepresentableValues() async throws {
    enum Value: Int {
      case one
      case two
    }
    UserDefaults.standard.removeObject(forKey: "raw")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Value?> = [nil, .one, .two, .one][...]
          for await value in self.userDefaults.rawRepresentableValues(Value.self, forKey: "raw")
          {
            XCTAssertEqual(value, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.one, forKey: "raw")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.two, forKey: "raw")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(Value.one, forKey: "raw")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "raw")
  }

  func testLiveUserDefaultsDateValues() async throws {
    UserDefaults.standard.removeObject(forKey: "date")
    let date1 = Date(timeIntervalSince1970: 0)
    let date2 = Date(timeIntervalSince1970: 1)
    let date3 = Date(timeIntervalSince1970: 7)
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Date?> = [nil, date1, date2, date3][...]
          for await url in self.userDefaults.dateValues(forKey: "date") {
            XCTAssertEqual(url, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(date1, forKey: "date")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(date2, forKey: "date")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(date3, forKey: "date")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "date")
  }

  func testLiveUserDefaultsIntValues() async throws {
    UserDefaults.standard.removeObject(forKey: "int")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [nil, 1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "int")
  }

  func testLiveUserDefaultsIntValuesWithValue() async throws {
    UserDefaults.standard.removeObject(forKey: "int")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      self.userDefaults.set(42, forKey: "int")
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [42, 1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "int")
  }

  func testLiveUserDefaultsIntValuesWithValueDeduplicated() async throws {
    UserDefaults.standard.removeObject(forKey: "int")
    await withDependencies {
      $0.userDefaults = .liveValue
    } operation: {
      self.userDefaults.set(1, forKey: "int")
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
    UserDefaults.standard.removeObject(forKey: "int")
  }

  func testEphemeralUserDefaultsIntValues() async throws {
    await withDependencies {
      $0.userDefaults = .ephemeral()
    } operation: {
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [nil, 1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
  }

  func testEphemeralUserDefaultsIntValuesWithValue() async throws {
    await withDependencies {
      $0.userDefaults = .ephemeral()
    } operation: {
      self.userDefaults.set(42, forKey: "int")
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [42, 1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
  }

  func testEphemeralUserDefaultsIntValuesWithValueDeduplicated() async throws {
    await withDependencies {
      $0.userDefaults = .ephemeral()
    } operation: {
      self.userDefaults.set(1, forKey: "int")
      await withTimeout { group in
        group.addTask {
          var expectations: ArraySlice<Int?> = [1, 4, 7][...]
          for await int in self.userDefaults.integerValues(forKey: "int") {
            XCTAssertEqual(int, expectations.first)
            expectations = expectations.dropFirst()
            if expectations.isEmpty { break }
          }
        }
        group.addTask {
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(1, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(4, forKey: "int")
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
          self.userDefaults.set(7, forKey: "int")
        }
      }
    }
  }
}

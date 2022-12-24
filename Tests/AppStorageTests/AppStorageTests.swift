import AppStorage
import Dependencies
import XCTest

final class AppStorageTests: XCTestCase {
  func testAppStorage() {
    enum RawRep: String {
      case first
      case second
    }
    @AppStorage("SomeKey") var int = 42
    @AppStorage("SomeKey") var sameInt: Int?
    @AppStorage("RawRep") var rawRep: RawRep = .first

    DependencyValues.withValue(\.userDefaults, .ephemeral()) {
      XCTAssertEqual(int, 42)
      int = 1969
      XCTAssertEqual(int, 1969)
      XCTAssertEqual(int, sameInt)
      XCTAssertEqual(rawRep, .first)
      rawRep = .second
      XCTAssertEqual(rawRep, .second)
    }
  }

  func testDynamicAppStorageResolution() {
    let userDefaults1 = UserDefaults.Dependency.ephemeral()
    let userDefaults2 = UserDefaults.Dependency.ephemeral()

    @AppStorage("SomeKey") var int1 = 42
    @AppStorage("SomeKey", store: userDefaults2) var int2 = 44

    DependencyValues.withValue(\.userDefaults, userDefaults1) {
      XCTAssertEqual(int1, 42)
      XCTAssertEqual(int2, 44)
      int1 = 1969
      int2 = -52
      XCTAssertEqual(int1, 1969)
      XCTAssertEqual(int2, -52)
    }
  }

  @available(iOS 16.0, macOS 13.0, *)
  func testStream() async throws {
    @AppStorage("SomeKey") var int = 42

    try await DependencyValues.withValue(\.userDefaults, .ephemeral()) {
      try await withThrowingTaskGroup(of: AsyncEnumerationTestStatus.self) { group in
        group.addTask {
          var expectations: [Int] = [42, 55, 42, 20, 446, 42]
          for await element in $int.values() {
            let expected = expectations.removeFirst()
            XCTAssertEqual(element, expected)
            if expectations.isEmpty {
              break
            }
          }
          return .enumerationDidFinish
        }
        group.addTask {
          /// Let the first value hit the enumeration
          try await Task.sleep(for: .milliseconds(50))
          $int.set(55)
          try await Task.sleep(for: .milliseconds(50))
          $int.wrappedValue = 42  // Alternative
          try await Task.sleep(for: .milliseconds(50))
          $int.set(20)
          try await Task.sleep(for: .milliseconds(50))
          $int.set(446)
          try await Task.sleep(for: .milliseconds(50))
          $int.reset()
          return .controlDidFinish
        }
        group.addTask {
          try await Task.sleep(for: .seconds(1))
          throw TimeOutError()
        }
        
        while !group.isEmpty {
          do {
            if try await group.next() == .enumerationDidFinish {
              group.cancelAll()
            }
          } catch {
            if error is CancellationError {
              return
            } else {
              throw error
            }
          }
        }
      }
    }
  }

  func testLiveURLAppStorage() {
    let url1 = URL(string: "https://pointfree.co/")!
    let url2 = URL(string: "https://www.google.com/")!
    let fileURL1 = FileManager.default.temporaryDirectory.appendingPathComponent("1")
    let fileURL2 = FileManager.default.temporaryDirectory.appendingPathComponent("2")

    UserDefaults.standard.removeObject(forKey: "URL")
    UserDefaults.standard.removeObject(forKey: "FileURL")
    defer {
      UserDefaults.standard.removeObject(forKey: "URL")
      UserDefaults.standard.removeObject(forKey: "FileURL")
    }

    @AppStorage("URL") var url = url1
    @AppStorage("FileURL") var fileURL: URL = fileURL1

    @AppStorage("URL") var sameURL: URL?
    @AppStorage("FileURL") var sameFileURL: URL?

    XCTAssertEqual(url, url1)
    XCTAssertEqual(fileURL, fileURL1)

    url = url2
    XCTAssertEqual(url, url2)
    XCTAssertEqual(url, sameURL)

    fileURL = fileURL2
    XCTAssertEqual(fileURL, fileURL2)
    XCTAssertEqual(fileURL, sameFileURL)
  }

  @available(iOS 16.0, macOS 13.0, *)
  func testLiveStream() async throws {
    @AppStorage("SomeKey") var int = 42

    UserDefaults.standard.removeObject(forKey: "SomeKey")
    defer {
      UserDefaults.standard.removeObject(forKey: "SomeKey")
    }
    try await withThrowingTaskGroup(of: AsyncEnumerationTestStatus.self) { group in
      group.addTask {
        var expectations: [Int] = [42, 55, 42, 20, 446, 42]
        for await element in $int.values() {
          let expected = expectations.removeFirst()
          XCTAssertEqual(element, expected)
          if expectations.isEmpty {
            break
          }
        }
        return .enumerationDidFinish
      }
      group.addTask {
        /// Let the first value hit the enumeration
        try await Task.sleep(for: .milliseconds(50))
        $int.set(55)
        try await Task.sleep(for: .milliseconds(50))
        $int.set(42)
        try await Task.sleep(for: .milliseconds(50))
        $int.set(20)
        try await Task.sleep(for: .milliseconds(50))
        $int.set(446)
        try await Task.sleep(for: .milliseconds(50))
        $int.reset()
        return .controlDidFinish
      }
      
      group.addTask {
        try await Task.sleep(for: .seconds(1))
        throw TimeOutError()
      }
      
      while !group.isEmpty {
        do {
          if try await group.next() == .enumerationDidFinish {
            group.cancelAll()
          }
        } catch {
          if error is CancellationError {
            return
          } else {
            throw error
          }
        }
      }
    }
  }
}

private enum AsyncEnumerationTestStatus {
  case enumerationDidFinish
  case controlDidFinish
}
private struct TimeOutError: Error {}

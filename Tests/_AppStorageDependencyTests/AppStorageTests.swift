import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import UserDefaultsDependency
import XCTest
import _AppStorageDependency

final class AppStorageTests: XCTestCase {
  func testAppStorage() {
    enum RawRep: String {
      case first
      case second
    }
    @Dependency.AppStorage("SomeKey") var int = 42
    @Dependency.AppStorage("SomeKey") var sameInt: Int?
    @Dependency.AppStorage("RawRep") var rawRep: RawRep = .first

    // This passes
    withDependencies {
      $0.userDefaults = .ephemeral()
    } operation: {
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

    @Dependency.AppStorage("SomeKey") var int1 = 42
    @Dependency.AppStorage("SomeKey", store: userDefaults2) var int2 = 44

    withDependencies {
      $0.userDefaults = userDefaults1
    } operation: {
      XCTAssertEqual(int1, 42)
      XCTAssertEqual(int2, 44)
      int1 = 1969
      int2 = -52
      XCTAssertEqual(int1, 1969)
      XCTAssertEqual(int2, -52)
    }
  }
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    func testStream() async throws {
      final class Model: @unchecked Sendable {
        @Dependency.AppStorage("SomeKey") var int = 42
      }
      let model = Model()
      await withDependencies {
        $0.userDefaults = .ephemeral()
      } operation: {
        await withTimeout(2000) { group in
          group.addTask {
            let expectations: [Int] = [42, 55, 42, 20, 446, 42]
            var index = 0
            for await element in model.$int {
              XCTAssertEqual(element, expectations[index])
              index += 1
              if index == expectations.endIndex {
                return
              }
            }
          }
          group.addTask {
            /// Let the first value hit the enumeration
            try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
            model.int = 55
            try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
            model.int = 42
            try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
            model.int = 20
            try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
            model.int = 446
            try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
            model.$int.reset()
          }
        }
      }
    }
  #endif
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
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

      @Dependency.AppStorage("URL") var url = url1
      @Dependency.AppStorage("FileURL") var fileURL: URL = fileURL1

      @Dependency.AppStorage("URL") var sameURL: URL?
      @Dependency.AppStorage("FileURL") var sameFileURL: URL?

      withDependencies {
        $0.context = .live
      } operation: {
        XCTAssertEqual(url, url1)
        XCTAssertEqual(fileURL, fileURL1)

        url = url2
        XCTAssertEqual(url, url2)
        XCTAssertEqual(url, sameURL)

        fileURL = fileURL2
        XCTAssertEqual(fileURL, fileURL2)
        XCTAssertEqual(fileURL, sameFileURL)
      }
    }

    func testLiveStream() async throws {

      final class Model: @unchecked Sendable {
        @Dependency.AppStorage("SomeKey") var int = 42
      }

      let model = withDependencies {
        $0.userDefaults = .standard
      } operation: {
        Model()
      }

      UserDefaults.standard.removeObject(forKey: "SomeKey")
      defer {
        UserDefaults.standard.removeObject(forKey: "SomeKey")
      }
      await withTimeout(2000) { group in
        group.addTask {
          let expectations: [Int] = [42, 55, 42, 20, 446, 42]
          var index = 0
          for await element in model.$int {
            XCTAssertEqual(element, expectations[index])
            index += 1
            if index == expectations.endIndex {
              return
            }
          }
        }
        group.addTask {
          /// Let the first value hit the enumeration
          try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
          model.int = 55
          try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
          model.int = 42
          try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
          model.int = 20
          try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
          model.int = 446
          try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
          model.$int.reset()
        }
      }
    }
  #endif
}

import Dependencies
@_spi(Internals) import DependenciesAdditions
import SwiftUI
import XCTest

@_spi(Internals) import _SwiftUIDependency

enum TestEnvironmentKey: EnvironmentKey {
  static var defaultValue: Int { 0 }
}

extension EnvironmentValues {
  var test: Int {
    get { self[TestEnvironmentKey.self] }
    set { self[TestEnvironmentKey.self] = newValue }
  }
}

@MainActor
final class SwiftUIEnvironmentTests: XCTestCase {
  func testSwiftUIEnvironment() async throws {
    @Dependency.Environment(\.test) var testValue
    let _ = ()  // Separator, as swift-format removes the terminal semicolon above
    // and the compiler doesn't like it.

    await withTimeout(2000) { group in
      group.addTask { @MainActor in
        let expected: [Int?] = [nil, 1, 3, nil, 5, 8, 10]
        var index = 0
        for await value in $testValue {
          XCTAssertEqual(value, expected[index])
          index += 1
          if index == expected.endIndex { return }
        }
      }
      group.addTask { @MainActor in
        let environment = SwiftUIEnvironment.shared
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(1, keyPath: \.test)
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(3, keyPath: \.test)
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(nil, keyPath: \.test)
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(5, keyPath: \.test)
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(8, keyPath: \.test)
        try await Task.sleep(nanoseconds: 200 * NSEC_PER_MSEC)
        environment.update(10, keyPath: \.test)
      }
    }
  }
}

import Dependencies
import DependenciesAdditions
import SwiftUI
@testable import SwiftUIEnvironment
import XCTest

enum TestEnvironmentKey: EnvironmentKey {
  static var defaultValue: Int { 0 }
}

extension EnvironmentValues {
  var test: Int {
    get { self[TestEnvironmentKey.self] }
    set { self[TestEnvironmentKey.self] = newValue }
  }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
final class SwiftUIEnvironmentTests: XCTestCase {
  func testSwiftUIEnvironment() async throws {
    @Dependency(\.environment.streams.test) var testValue

    try await withTimeout(.seconds(1)) { group in
      group.addTask { @MainActor in
        let expected: [Int?] = [nil, 1, 3, nil, 5, 8, 10]
        var index = 0
        for await value in testValue {
          XCTAssertEqual(value, expected[index])
          index += 1
          if index == expected.endIndex - 1 { return }
        }
      }
      group.addTask { @MainActor in
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(1, keyPath: \.test)
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(3, keyPath: \.test)
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(nil, keyPath: \.test)
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(5, keyPath: \.test)
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(8, keyPath: \.test)
        try await Task.sleep(for: .milliseconds(100))
        SwiftUIEnvironment.shared.update(10, keyPath: \.test)
      }
    }
  }
}


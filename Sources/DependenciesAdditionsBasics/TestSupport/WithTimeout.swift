import Foundation
import XCTestDynamicOverlay
#if os(Linux)
let NSEC_PER_MSEC: UInt64 = 1_000_000
#endif

/// Performs an async operation that fails if it hasn't finished before a timeout expires.
///
/// - Parameters:
///   - milliseconds: The timeout after which the test fails, in milliseconds. 1000ms by default.
///   - description: The description message to show when the test fails.
///   - operation: The operation to perform before the timeout expires.
@_spi(Internals) public func withTimeout(
  _ milliseconds: UInt64 = 1000,
  description: String = "",
  operation: @Sendable @escaping () async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async rethrows {
  try await withThrowingTaskGroup(of: Void.self) { group in
    group.addTask(operation: operation)
    group.addTask {
      try await Task.sleep(nanoseconds: milliseconds * NSEC_PER_MSEC)
      XCTFail(description, file: file, line: line)
    }
    defer { group.cancelAll() }
    try await group.next()
  }
}

/// Performs an async operation that fails if it hasn't finished before a timeout expires.
///
/// A `ThrowingTaskGroup` argument is provided. You can accumulate concurrent units of works to it.
/// All operations must have finished before the timeout is reached, or the test will fail.
/// - Parameters:
///   - milliseconds: The timeout after which the test fails, in milliseconds. 1000ms by default.
///   - description: The description message to show when the test fails.
///   - operations: The operations to perform before the timeout expires.
@_spi(Internals) public func withTimeout(
  _ milliseconds: UInt64 = 1000,
  description: String = "",
  group operations: @escaping @Sendable (inout ThrowingTaskGroup<Void, Error>) async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async rethrows {
  try await withTimeout(
    milliseconds,
    description: description,
    operation: {
      try await withThrowingTaskGroup(of: Void.self) { group in
        try await operations(&group)
        try await group.waitForAll()
      }
    },
    file: file,
    line: line
  )
}

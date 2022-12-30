import Foundation
import XCTestDynamicOverlay

@_spi(Internal) public func withTimeout(
  _ milliseconds: UInt64 = 1000,
  description: String = "",
  operation: @Sendable @escaping () async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  try await withThrowingTaskGroup(of: Void.self) { group in
    group.addTask(operation: operation)
    group.addTask {
      try await Task.sleep(nanoseconds: milliseconds * NSEC_PER_MSEC)
      XCTFail(description, file: file, line: line)
    }
    try await group.next()
    group.cancelAll()
  }
}

@_spi(Internal) public func withTimeout(
  _ milliseconds: UInt64 = 1000,
  description: String = "",
  group operations: @escaping @Sendable (inout ThrowingTaskGroup<Void, Error>) async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  try await withTimeout(
    milliseconds,
    description: description,
    operation: {
      try await withThrowingTaskGroup(of: Void.self) { group in
        try await operations(&group)
        while !group.isEmpty {
          try await group.next()
        }
      }
    },
    file: file,
    line: line
  )
}

import Dependencies
import Foundation

extension AsyncStream {
  public init<S: AsyncSequence>(_ sequence: @escaping () async -> S)
  where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = await sequence().makeAsyncIterator()
      }
      return try? await iterator?.next()
    }
  }
}

extension AsyncThrowingStream where Failure == Error {
  public init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S) throws
  where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = try await sequence().makeAsyncIterator()
      }
      return try await iterator?.next()
    }
  }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withTimeout(
  _ duration: Duration = .milliseconds(100),
  description: String = "",
  operation: @Sendable @escaping () async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  try await withThrowingTaskGroup(of: Void.self) { group in
    group.addTask(operation: operation)
    group.addTask {
      try await Task.sleep(for: duration)
      XCTFail(description, file: file, line: line)
    }
    try await group.next()
    group.cancelAll()
  }
}
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withTimeout(
  _ duration: Duration = .milliseconds(100),
  description: String = "",
  group operations: @escaping @Sendable (inout ThrowingTaskGroup<Void, Error>) async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async throws {
  try await withTimeout(
    duration,
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

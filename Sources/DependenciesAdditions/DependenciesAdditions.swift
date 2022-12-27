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

// A type that is able to broadcast continuation messages to an arbitrary number of
// `AsyncStream`s it can generate.
public final class _AsyncSharedSubject<Value>: Sendable {
  public enum Behavior: Sendable {
    case replayCurrentValue
    case awaitForNewValues
  }
  let continuations = LockIsolated([UUID: AsyncStream<Value>.Continuation]())
  let currentValue = LockIsolated<Value?>(nil)
  let initialValueBehavior: Behavior
  
  public init(initialValueBehavior: Behavior = .awaitForNewValues) {
    self.initialValueBehavior = initialValueBehavior
  }
  
  public func yield(_ value: Value) {
    currentValue.withValue {
      $0 = value
    }
    continuations.withValue {
      for continuation in $0.values {
        continuation.yield(value)
      }
    }
  }
  
  public func finish() {
    continuations.withValue {
      for continuation in $0.values {
        continuation.finish()
      }
      $0 = [:]
    }
  }

  public func stream(
    bufferingPolicy: AsyncStream<Value>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<Value> {
    AsyncStream(Value.self, bufferingPolicy: bufferingPolicy) { continuation in
      let id = UUID()
      continuations.withValue {
        $0[id] = continuation
      }
      // Capturing `self` here makes all clients retains this instance.
      // If we'd choose to capture it weakly instead, we would need to call `finish()`
      // on each continuation in `deinit`.
      continuation.onTermination = { _ in
        self.continuations.withValue {
          $0[id] = nil
        }
      }
      if self.initialValueBehavior == .replayCurrentValue {
        currentValue.withValue { value in
          if let value {
            continuation.yield(value)
          }
        }
      }
    }
  }
}

public func withTimeout(
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

public func withTimeout(
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

import Dependencies
import Foundation

// A type that is able to broadcast continuation messages to an arbitrary number of
// `AsyncStream`s it can generate.
public final class AsyncSharedSubject<Value>: Sendable {
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

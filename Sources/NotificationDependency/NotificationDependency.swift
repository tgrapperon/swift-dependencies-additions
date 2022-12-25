import Dependencies
import Foundation

public struct NotificationObservationOf<Value>: Hashable, Sendable {
  let name: Notification.Name
  let object: UncheckedSendable<NSObject>?
  let transform: @Sendable (Notification) async throws -> Value
  let file: StaticString
  let line: UInt

  public init(
    _ name: Notification.Name,
    object: UncheckedSendable<NSObject>?,
    transform: @escaping @Sendable (Notification) -> Value = { $0 },
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.name = name
    self.object = object
    self.transform = transform
    self.file = file
    self.line = line
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    guard
      lhs.name == rhs.name,
      lhs.object == rhs.object,
      lhs.file.description == rhs.file.description,
      lhs.line == rhs.line
    else { return false }
    return true
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(object)
    hasher.combine(file.description)
    hasher.combine(line)
  }
}

struct NotificationCenterDependency {
  private let stream: @Sendable (Any) -> Any
  init<Value>(stream: @escaping @Sendable (NotificationObservationOf<Value>) -> AsyncStream<Value>) {
    self.stream = { stream($0 as! NotificationObservationOf<Value>) }
  }
  subscript<Value>(notification: Notification.Name) -> AsyncStream<Value> {
    let observation = NotificationObservationOf<Notification>(
      notification,
      object: nil
    )
    return self.stream(observation) as! AsyncStream<Value>
  }
  
  subscript<Value>(notification: NotificationObservationOf<Value>) -> AsyncStream<Value> {
    self.stream(notification) as! AsyncStream<Value>
  }
}

extension NotificationCenterDependency: DependencyKey {
  static var liveValue: NotificationCenterDependency { fatalError() }
  static var testValue: NotificationCenterDependency { fatalError() }
}

extension NotificationCenterDependency {
  @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
  static let system = NotificationCenterDependency { notificationObservation in
    return AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
      let task = Task {
        for await notification in NotificationCenter.default.notifications(
          named: notificationObservation.name)
        {
          do {
            let value = try await notificationObservation.transform(notification)
            continuation.yield(value)
          } catch {
            continuation.finish()
          }
        }
      }
      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}



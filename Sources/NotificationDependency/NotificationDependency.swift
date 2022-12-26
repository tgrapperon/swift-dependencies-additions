import Dependencies
import Foundation

extension DependencyValues {
  public var notifications: any NotificationCenterProtocol {
    get { self[NotificationCenterKey.self] }
    set { self[NotificationCenterKey.self] = newValue }
  }
}

enum NotificationCenterKey: DependencyKey {
  static var liveValue: any NotificationCenterProtocol { .default }
  static var testValue: NotificationCenterProtocol {
    XCTFail(#"Unimplemented: @Dependency(\.notifications)"#)
    return .default
  }
}

public struct Notifications {}
//// Test
//extension Notifications {
//  var didBecomeSingleTreaded: ObservationOf<Notification> {
//    .init(.NSDidBecomeSingleThreaded)
//  }
//}
//
//func test() {
//  @Dependency(\.notifications) var notifications
//  @Dependency(\.notifications.didBecomeSingleTreaded) var didBecomeSingleTreaded;
//
//  notifications.post(.init(name: .NSDidBecomeSingleThreaded))
//}

extension Notifications {
  public struct ObservationOf<Value>: Hashable, Sendable {
    let name: Notification.Name
    let object: UncheckedSendable<NSObject>?
    let transform: @Sendable (Notification) throws -> Value
    let notify: (@Sendable (Value) -> Notification?)?
    let id: ID

    public init(
      _ name: Notification.Name,
      object: NSObject? = nil,
      transform: @escaping @Sendable (Notification) throws -> Value = { $0 },
      notify: (@Sendable (Value) -> Notification?)? = nil,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.name = name
      self.object = object.map(UncheckedSendable.init(wrappedValue:))
      self.transform = transform
      self.notify = notify
      self.id = ID(
        name: name,
        object: object.map { ObjectIdentifier($0) },
        file: file.description,
        line: line,
        valueType: ObjectIdentifier(Value.self)
      )
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(self.id)
    }
    
    var notification: Notification {
      Notification(name: self.name, object: self.object?.wrappedValue)
    }
    
    public func map<T>(
      transform: @escaping @Sendable (Value) throws -> T,
      notify: (@Sendable (T) -> Value?)? = nil,
      file: StaticString = #fileID,
      line: UInt = #line
    ) -> ObservationOf<T> {
      return .init(
        self.name,
        object: self.object?.wrappedValue
      ) {
        try transform(self.transform($0))
      } notify: {
        guard
          let selfNotify = self.notify,
          let value = notify?($0)
        else { return nil }
        return selfNotify(value)
      }
    }
  }
}

extension Notifications {
  public struct StreamOf<Value>: Sendable {
    // TODO: Implement throwing version?
    private let post: @Sendable (Value) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    init(
      post: @escaping @Sendable (Value) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.post = post
      self.stream = stream
    }
    
    public func callAsFunction() -> AsyncStream<Value> {
      self.stream()
    }
    public func post(_ value: Value) {
      self.post(value)
    }
  }
}

extension Notifications {
  struct ID: Hashable, Sendable {
    let name: Notification.Name
    let object: ObjectIdentifier?
    let file: String
    let line: UInt
    let valueType: ObjectIdentifier
  }
}

@dynamicMemberLookup
public protocol NotificationCenterProtocol: Sendable {
  func post(_ notification: Notification)
  subscript<Value>(notification: Notifications.ObservationOf<Value>) -> Notifications.StreamOf<Value> { get }
  // The subscript for @dynamicMemberLookup needs to be declared at the protocol
  // level or it crashes when trying to build of testing
  // TODO: Report this
  subscript<Value>(dynamicMember keyPath: KeyPath<Notifications, Notifications.ObservationOf<Value>>) -> Notifications.StreamOf<Value> { get }
}

extension NotificationCenterProtocol {
  public subscript<Value>(dynamicMember keyPath: KeyPath<Notifications, Notifications.ObservationOf<Value>>) -> Notifications.StreamOf<Value> {
    self[Notifications()[keyPath: keyPath]]
  }
}

extension NotificationCenterProtocol where Self == _DefaultNotificationCenter {
  public static var `default`: _DefaultNotificationCenter { _DefaultNotificationCenter() }
}

extension NotificationCenterProtocol where Self == _ControllableNotificationCenter {
  public static var controllable: _ControllableNotificationCenter { _ControllableNotificationCenter() }
}

public struct _DefaultNotificationCenter: NotificationCenterProtocol {
  private let streams = LockIsolated([Notifications.ID: any Sendable]())

  public func post(_ notification: Notification) {
    NotificationCenter.default.post(notification)
  }
  
  public subscript<Value>(notification: Notifications.ObservationOf<Value>) -> Notifications.StreamOf<Value> {
    self.streams.withValue { (streams) -> Notifications.StreamOf<Value> in
      if let existing = streams[notification.id] as! Notifications.StreamOf<Value>? {
        return existing
      }
      let stream = Notifications.StreamOf<Value> { value in
        if let notification = notification.notify?(value) {
          NotificationCenter.default.post(notification)
        } else if let notification = value as? Notification {
          NotificationCenter.default.post(notification)
        } else {
          XCTFail("TODO: Explain why it is not supported to send values directly without `notify`")
        }
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          let observer = NotificationObserver {
            do {
              let value = try notification.transform($0)
              continuation.yield(value)
            } catch {
              continuation.finish()
            }
          }

          NotificationCenter.default.addObserver(
            observer,
            selector: #selector(NotificationObserver.onNotification(notification:)),
            name: notification.name,
            object: notification.object?.value
          )

          continuation.onTermination = { _ in
            NotificationCenter.default.removeObserver(
              observer,
              name: notification.name,
              object: notification.object?.value
            )
          }
        }
      }
      streams[notification.id] = stream
      return stream
    }
  }
  
  private final class NotificationObserver: NSObject, Sendable {
    let onNotification: @Sendable (Notification) -> Void
    init(onNotification: @escaping @Sendable (Notification) -> Void) {
      self.onNotification = onNotification
      super.init()
    }
    @objc func onNotification(notification: Notification) {
      self.onNotification(notification)
    }
  }
}

public struct _ControllableNotificationCenter: NotificationCenterProtocol {
  // Bundles a `Notifications.StreamOf` and its `SharedAsyncStreamsContinuation`
  internal struct StreamAndSharedContinuations: Sendable {
    let notificationStream: any Sendable
    let postedSharedContinuations: any Sendable
    
    func notificationStream<T>(of type: T.Type) -> Notifications.StreamOf<T> {
      notificationStream as! Notifications.StreamOf<T>
    }
    func postedSharedContinuation<T>(of type: T.Type) -> SharedAsyncStreamsContinuation<T> {
      postedSharedContinuations as! SharedAsyncStreamsContinuation<T>
    }
  }
  
  private let notifications = SharedAsyncStreamsContinuation<Notification>()
  private let streams = LockIsolated([Notifications.ID: StreamAndSharedContinuations]())
  
  public func post(_ notification: Notification) {
    notifications.yield(notification)
  }
  
  public subscript<Value>(notification: Notifications.ObservationOf<Value>) -> Notifications.StreamOf<Value> {
    return self.streams.withValue { streams in
      if let existing = streams[notification.id]?.notificationStream(of: Value.self) {
        return existing
      }
      let postedValues = SharedAsyncStreamsContinuation<Result<Value, Error>>()
      let notificationStream = Notifications.StreamOf<Value>{ postedValue in
        if let notification = notification.notify?(postedValue) {
          self.post(notification)
        } else {
          postedValues.yield(.success(postedValue))
        }
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          let task = Task {
            await withTaskGroup(of: Void.self) { group in
              // Loop over regular notifications
              group.addTask {
                for await emitted in notifications.stream() {
                  do {
                    let value = try notification.transform(emitted)
                    continuation.yield(value)
                  } catch {
                    continuation.finish()
                    return
                  }
                }
              }
              // Loop over sent values
              group.addTask {
                for await posted in postedValues.stream() {
                  switch posted {
                  case let .success(value):
                    continuation.yield(value)
                  case .failure:
                    continuation.finish()
                  }
                }
              }
              await group.next()
              group.cancelAll()
            }
          }
          
          continuation.onTermination = { _ in
            task.cancel()
          }
        }
      }
      streams[notification.id] = StreamAndSharedContinuations(
        notificationStream: notificationStream,
        postedSharedContinuations: postedValues
      )
      return notificationStream
    }
  }
}

// A type that is able to broadcast continuation messages to an arbitrary number of
// `AsyncStream`s it can generate.
internal final class SharedAsyncStreamsContinuation<Value>: Sendable {
  let continuations = LockIsolated([UUID: AsyncStream<Value>.Continuation]())

  func yield(_ value: Value) {
    continuations.withValue {
      for continuation in $0.values {
        continuation.yield(value)
      }
    }
  }
  
  func finish() {
    continuations.withValue {
      for continuation in $0.values {
        continuation.finish()
      }
      $0 = [:]
    }
  }

  func stream() -> AsyncStream<Value> {
    AsyncStream(Value.self) { continuation in
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
    }
  }
}


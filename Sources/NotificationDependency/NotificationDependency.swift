import Dependencies
import Foundation

public struct NotificationObservationOf<Value>: Hashable, Sendable {
  let name: Notification.Name
  let object: UncheckedSendable<NSObject>?
  let transform: @Sendable (Notification) throws -> Value
  let notify: (@Sendable (Value) -> Notification?)?
  let id: NotificationID

  public init(
    _ name: Notification.Name,
    object: UncheckedSendable<NSObject>? = nil,
    transform: @escaping @Sendable (Notification) -> Value = { $0 },
    notify: (@Sendable (Value) -> Notification?)? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.name = name
    self.object = object
    self.transform = transform
    self.notify = notify
    self.id = NotificationID(
      name: name,
      object: object.map { ObjectIdentifier($0.wrappedValue) },
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
}

struct NotificationID: Hashable, Sendable {
  let name: Notification.Name
  let object: ObjectIdentifier?
  let file: String
  let line: UInt
  let valueType: ObjectIdentifier
}

public struct NotificationStreamOf<Value>: Sendable {
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

public protocol NotificationCenterProtocol: Sendable {
  func post(notification: Notification)
  subscript<Value>(notification: NotificationObservationOf<Value>) -> NotificationStreamOf<Value> { get }
}

extension NotificationCenterProtocol where Self == _DefaultNotificationCenter {
  public static var `default`: _DefaultNotificationCenter { _DefaultNotificationCenter() }
}

extension NotificationCenterProtocol where Self == _ControllableNotificationCenter {
  public static var controllable: _ControllableNotificationCenter { _ControllableNotificationCenter() }
}

public struct _DefaultNotificationCenter: NotificationCenterProtocol {
  let streams = LockIsolated([NotificationID: any Sendable]())

  public func post(notification: Notification) {
    NotificationCenter.default.post(notification)
  }
  
  public subscript<Value>(notification: NotificationObservationOf<Value>) -> NotificationStreamOf<Value> {
    self.streams.withValue { (streams) -> NotificationStreamOf<Value> in
      if let existing = streams[notification.id] as! NotificationStreamOf<Value>? {
        return existing
      }
      let stream = NotificationStreamOf<Value> { value in
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
  // Bundles a `NotificationStreamOf` and its `SharedAsyncStreamsContinuation`
  struct StreamAndSharedContinuations: Sendable {
    let notificationStream: any Sendable
    let postedSharedContinuations: any Sendable
    
    func notificationStream<T>(of type: T.Type) -> NotificationStreamOf<T> {
      notificationStream as! NotificationStreamOf<T>
    }
    func postedSharedContinuation<T>(of type: T.Type) -> SharedAsyncStreamsContinuation<T> {
      postedSharedContinuations as! SharedAsyncStreamsContinuation<T>
    }
  }
  
  let notifications = SharedAsyncStreamsContinuation<Notification>()
  let streams = LockIsolated([NotificationID: StreamAndSharedContinuations]())
  
  public func post(notification: Notification) {
    notifications.yield(notification)
  }
  
  public subscript<Value>(notification: NotificationObservationOf<Value>) -> NotificationStreamOf<Value> {
    return self.streams.withValue { streams in
      if let existing = streams[notification.id]?.notificationStream(of: Value.self) {
        return existing
      }
      let postedValues = SharedAsyncStreamsContinuation<Result<Value, Error>>()
      let notificationStream = NotificationStreamOf<Value>{ postedValue in
        if let notification = notification.notify?(postedValue) {
          self.post(notification: notification)
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

enum NotificationCenterKey: DependencyKey {
  static var liveValue: any NotificationCenterProtocol {
    _DefaultNotificationCenter()
  }
  static var testValue: NotificationCenterProtocol {
    XCTFail(#"Unimplemented: @Dependency(\.notifications)"#)
    return _DefaultNotificationCenter()
  }
}

extension DependencyValues {
  public var notifications: any NotificationCenterProtocol {
    get { self[NotificationCenterKey.self] }
    set { self[NotificationCenterKey.self] = newValue }
  }
}

final class SharedAsyncStreamsContinuation<Value>: Sendable {
  let continuations = LockIsolated([UUID: AsyncStream<Value>.Continuation]())

  func yield(_ value: Value) {
    continuations.withValue {
      for continuation in $0.values {
        continuation.yield(value)
      }
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

import Dependencies
@_spi(Internal) import DependenciesAdditions
import Foundation

extension NotificationCenterProtocol where Self == _ControllableNotificationCenter {
  public static var controllable: _ControllableNotificationCenter {
    _ControllableNotificationCenter()
  }
}

public struct _ControllableNotificationCenter: NotificationCenterProtocol {
  // Bundles a `Notifications.StreamOf` and its `SharedAsyncStreamsContinuation`
  internal struct StreamAndSharedContinuations: Sendable {
    let notificationStream: any Sendable
    let postedSharedContinuations: any Sendable

    func notificationStream<T>(of type: T.Type) -> Notifications.StreamOf<T> {
      self.notificationStream as! Notifications.StreamOf<T>
    }

    func postedSharedContinuation<T>(of type: T.Type) -> _AsyncSharedSubject<T> {
      self.postedSharedContinuations as! _AsyncSharedSubject<T>
    }
  }

  private let notifications = _AsyncSharedSubject<Notification>()
  private let streams = LockIsolated([Notifications.ID: StreamAndSharedContinuations]())

  public func post(_ notification: Notification) {
    self.notifications.yield(notification)
  }

  public subscript<Value>(notification: Notifications.NotificationOf<Value>)
    -> Notifications.StreamOf<Value>
  {
    return self.streams.withValue { streams in
      if let existing = streams[notification.id]?.notificationStream(of: Value.self) {
        return existing
      }
      let postedValues = _AsyncSharedSubject<Result<Value, Error>>()
      let notificationStream = Notifications.StreamOf<Value>(notification: notification) { postedValue in
        var nsNotification = notification.notification
        notification.embed(postedValue, into: &nsNotification)
        self.post(nsNotification)
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          let task = Task {
            await withTaskGroup(of: Void.self) { group in
              // Loop over regular notifications
              group.addTask {
                for await emitted in notifications.stream() {
                  do {
                    let value = try notification.extract(from: emitted)
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

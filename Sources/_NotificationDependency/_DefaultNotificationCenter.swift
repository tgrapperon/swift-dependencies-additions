import Dependencies
import Foundation
@_spi(Internal) import DependenciesAdditions
import PathDependency

extension NotificationCenterProtocol where Self == _DefaultNotificationCenter {
  public static var `default`: _DefaultNotificationCenter { _DefaultNotificationCenter() }
}

public struct _DefaultNotificationCenter: NotificationCenterProtocol {
  private let streams = LockIsolated([Notifications.ID: any Sendable]())

  public func post(_ notification: Notification) {
    NotificationCenter.default.post(notification)
  }

  public subscript<Value>(notification: Notifications.NotificationOf<Value>) -> Notifications.StreamOf<Value> {
    self.streams.withValue { streams -> Notifications.StreamOf<Value> in
      if let existing = streams[notification.id] as! Notifications.StreamOf<Value>? {
        return existing
      }
      let stream = Notifications.StreamOf<Value> { value in
        var nsNotification = notification.notification
        notification.embed(value, &nsNotification)
        NotificationCenter.default.post(nsNotification)
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          let observer = NotificationObserver {
            do {
              let value = try notification.extract($0)
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

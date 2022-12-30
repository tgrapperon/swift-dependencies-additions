import Dependencies
import Foundation

// TODO: Convert to protocol witness?

extension DependencyValues {
  /// A type that abstract some `NotificationCenter`.
  ///
  public var notifications: NotificationCenter.Dependency {
    get { self[NotificationCenter.Dependency.self] }
    set { self[NotificationCenter.Dependency.self] = newValue }
  }
}

extension NotificationCenter.Dependency: DependencyKey {
  public static var liveValue: NotificationCenter.Dependency { .init() }
  public static var testValue: NotificationCenter.Dependency { .init() }
}

extension NotificationCenter {
  public struct Dependency: Sendable {
    typealias Notifications = _NotificationDependency.Notifications

    public func post(_ notification: Notification) {
      NotificationCenter.default.post(notification)
    }

    func stream<Value>(_ notification: Notifications.NotificationOf<Value>)
      -> Notifications.StreamOf<Value>
    {
      Notifications.StreamOf<Value>(notification: notification) { value in
        var nsNotification = notification.notification
        notification.embed(value, into: &nsNotification)
        NotificationCenter.default.post(nsNotification)
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          let observer = NotificationObserver {
            do {
              let value = try notification.extract(from: $0)
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
}

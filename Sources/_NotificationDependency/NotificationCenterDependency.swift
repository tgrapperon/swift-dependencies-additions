import Dependencies
import Foundation
import XCTestDynamicOverlay

// TODO: Convert to protocol witness?

extension DependencyValues {
  /// A type that abstracts some `NotificationCenter`.
  public var notificationCenter: NotificationCenter.Dependency {
    get { self[NotificationCenter.Dependency.self] }
    set { self[NotificationCenter.Dependency.self] = newValue }
  }
}

extension NotificationCenter.Dependency: DependencyKey {
  public static var liveValue: NotificationCenter.Dependency { .default }
  public static var testValue: NotificationCenter.Dependency { .unimplemented } // or `.default`?
  
  public static var `default`: Self { .init() }
  public static var unimplemented: Self { .init(TestNotificationCenter()) }
}

extension NotificationCenter {
  public struct Dependency: Sendable {
    typealias Notifications = _NotificationDependency.Notifications
    let notificationCenter: LockIsolated<NotificationCenter>

    public init(_ notificationCenter: @Sendable @autoclosure () -> NotificationCenter = .default) {
      self.notificationCenter = .init(notificationCenter())
    }

    public func post(_ notification: Notification, file: String = #file, line: UInt = #line) {
      self.notificationCenter.withValue {
        $0.post(notification, file: file, line: line)
      }
    }

    func stream<Value>(_ notification: Notifications.NotificationOf<Value>)
      -> Notifications.StreamOf<Value>
    {
      Notifications.StreamOf<Value>(notification) { value in
        self.notificationCenter.withValue {
          var nsNotification = notification.notification
          notification.embed(value, into: &nsNotification)
          $0.post(nsNotification, file: notification.id.file, line: notification.id.line)
        }
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

          self.notificationCenter.withValue {
            $0.addObserver(
              observer,
              selector: #selector(NotificationObserver.onNotification(notification:)),
              name: notification.name,
              object: notification.object?.value,
              file: notification.id.file,
              line: notification.id.line
            )
          }

          continuation.onTermination = { _ in
            self.notificationCenter.withValue {
              $0.removeObserver(
                observer,
                name: notification.name,
                object: notification.object?.value
              )
            }
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

extension NotificationCenter {
  @objc func post(_ notification: Notification, file: String, line: UInt) {
    post(notification)
  }

  @objc func addObserver(
    _ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?,
    object anObject: Any?, file: String, line: UInt
  ) {
    addObserver(observer, selector: aSelector, name: aName, object: anObject)
  }
}

final class TestNotificationCenter: NotificationCenter {
  override func post(_ notification: Notification, file: String, line: UInt) {
    XCTFail(
      #"Unimplemented: @Dependency(\.notificationCenter) when posting "\#(notification.name.rawValue)" at \#(file):\#(line)"#
    )
    post(notification)
  }

  override func addObserver(
    _ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?,
    object anObject: Any?, file: String, line: UInt
  ) {
    XCTFail(
      #"Unimplemented: @Dependency(\.notificationCenter) when observing "\#(aName!.rawValue)" at \#(file):\#(line)"#
    )
    super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
  }
}

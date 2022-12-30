import Dependencies
import Foundation
import XCTestDynamicOverlay

// TODO: Convert to protocol witness?

extension DependencyValues {
  /// An abstraction of a `NotificationCenter`.
  public var notificationCenter: NotificationCenter.Dependency {
    get { self[NotificationCenter.Dependency.self] }
    set { self[NotificationCenter.Dependency.self] = newValue }
  }
}

extension NotificationCenter.Dependency: DependencyKey {
  /// `.default` by default (!).
  public static var liveValue: NotificationCenter.Dependency { .default }
  /// `.unimplemented` by default.
  public static var testValue: NotificationCenter.Dependency { .unimplemented } // or `.default`?
  
  /// The default `NotificationCenter`
  public static var `default`: Self { .init() }
  /// An unimplemented `NotificationCenter` that fails during testing when its endpoints are
  /// reached.
  public static var unimplemented: Self { .init(TestNotificationCenter()) }
}

extension NotificationCenter {
  /// A type that abstracts a `NotificationCenter`.
  ///
  /// You mostly interact indirectly with this type by the mean of the `@Dependency.Notification`
  /// property wrapper.
  public struct Dependency: Sendable {
    typealias Notifications = _NotificationDependency.Notifications
    let notificationCenter: LockIsolated<NotificationCenter>

    
    /// Creates a new value from a `NotificationCenter` instance.
    ///
    /// You usually don't use this initializer directly, but instead use the `.default` and
    /// `.unimplemented` static variables.
    ///
    /// - Parameter notificationCenter: some `NotificationCenter` to base this value onto.
    public init(_ notificationCenter: @Sendable @autoclosure () -> NotificationCenter = .default) {
      self.notificationCenter = .init(notificationCenter())
    }

    // Note: we use a `String` for `#fileID` because the value comes from `ID` where it is
    // already a `String`.
    
    /// Posts a given `Notification` to the notification center.
    public func post(_ notification: Notification, file: String = #fileID, line: UInt = #line) {
      self.notificationCenter.withValue {
        $0.post(notification, file: file, line: line)
      }
    }

    func stream<Value>(_ notification: Notifications.NotificationOf<Value>)
      -> Notifications.StreamOf<Value>
    {
      Notifications.StreamOf<Value>(notification) { value, file, line in
        self.notificationCenter.withValue {
          var nsNotification = notification.notification
          notification.embed(value, into: &nsNotification)
          $0.post(nsNotification, file: file, line: line)
        }
      } stream: {
        AsyncStream(Value.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
          
          let observer = NotificationObserver {
            guard let value = notification.extract(from: $0) else { return }
            continuation.yield(value)
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

// This allows to pass `file` and `line` to `post` and `addObserve`, so `TestNotificationCenter`
// can provide better contextual information.
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

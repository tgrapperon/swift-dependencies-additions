@preconcurrency import Combine
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
  public static var testValue: NotificationCenter.Dependency { .unimplemented }

  public static var previewValue: NotificationCenter.Dependency { .default }
}

extension NotificationCenter.Dependency {
  /// The default `NotificationCenter`
  public static var `default`: Self { .init(.default) }
  /// An unimplemented `NotificationCenter` that fails during testing when its endpoints are
  /// reached.
  public static var unimplemented: Self {
    .init(
      post: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.notificationCenter.post)"#,
        placeholder: { @Sendable _, _, _, _, _ in () }),
      addObserver: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.notificationCenter.addObserver)"#,
        placeholder: { @Sendable _, _, _, _, _, _ in () }),
      removeObserver: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.notificationCenter.removeObserver)"#,
        placeholder: { @Sendable _, _, _, _, _ in () }),
      publisher: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.notificationCenter.publisher)"#,
        placeholder: { @Sendable _, _, _, _ in Empty().eraseToAnyPublisher() })
    )
  }
}

extension NotificationCenter {
  /// A type that abstracts a `NotificationCenter`.
  public struct Dependency: Sendable {
    let _post:
      @Sendable (NSNotification.Name, AnyObject?, [AnyHashable: Any]?, StaticString, UInt) -> Void
    let _addObserver:
      @Sendable (AnyObject, Selector, NSNotification.Name?, AnyObject?, StaticString, UInt) -> Void
    let _removeObserver:
      @Sendable (AnyObject, NSNotification.Name?, AnyObject?, StaticString, UInt) -> Void
    let _publisher:
      @Sendable (Notification.Name, AnyObject?, StaticString, UInt) -> AnyPublisher<
        Notification, Never
      >

    init(
      post: @escaping @Sendable (
        NSNotification.Name, AnyObject?, [AnyHashable: Any]?, StaticString, UInt
      ) -> Void,
      addObserver: @escaping @Sendable (
        AnyObject, Selector, NSNotification.Name?, AnyObject?, StaticString, UInt
      ) -> Void,
      removeObserver: @escaping @Sendable (
        AnyObject, NSNotification.Name?, AnyObject?, StaticString, UInt
      ) -> Void,
      publisher: @escaping @Sendable (Notification.Name, AnyObject?, StaticString, UInt) ->
        AnyPublisher<Notification, Never>
    ) {
      self._post = post
      self._addObserver = addObserver
      self._removeObserver = removeObserver
      self._publisher = publisher
    }

    public func post(
      name: NSNotification.Name, object: AnyObject? = nil, userInfo: [AnyHashable: Any]? = nil,
      file: StaticString = #fileID, line: UInt = #line
    ) {
      self._post(name, object, userInfo, file, line)
    }

    public func addObserver(
      _ observer: AnyObject, selector: Selector, name: NSNotification.Name?, object: AnyObject?,
      file: StaticString = #fileID, line: UInt = #line
    ) {
      self._addObserver(observer, selector, name, object, file, line)
    }

    public func removeObserver(
      _ observer: AnyObject, name: NSNotification.Name? = nil, object: AnyObject? = nil,
      file: StaticString = #fileID, line: UInt = #line
    ) {
      self._removeObserver(observer, name, object, file, line)
    }

    public func publisher(
      for name: Notification.Name, object: AnyObject? = nil, file: StaticString = #fileID,
      line: UInt = #line
    ) -> AnyPublisher<
      Notification, Never
    > {
      self._publisher(name, object, file, line)
    }
  }
}

extension NotificationCenter.Dependency {
  public func notifications(
    named name: Notification.Name,
    object: AnyObject? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> AsyncStream<Notification> {
    AsyncStream(Notification.self, bufferingPolicy: .bufferingNewest(0)) { continuation in
      final class Observer: NSObject, Sendable {
        let continuation: AsyncStream<Notification>.Continuation
        init(with continuation: AsyncStream<Notification>.Continuation) {
          self.continuation = continuation
          super.init()
        }

        @objc func onNotification(notification: Notification) {
          self.continuation.yield(notification)
        }
      }

      let observer = Observer(with: continuation)

      self.addObserver(
        observer,
        selector: #selector(Observer.onNotification(notification:)),
        name: name,
        object: object,
        file: file,
        line: line
      )
      let uncheckedObject = UncheckedSendable(object)
      continuation.onTermination = { _ in
        self.removeObserver(
          observer,
          name: name,
          object: uncheckedObject.wrappedValue
        )
      }
    }
  }
}

extension NotificationCenter.Dependency {
  public init(_ notificationCenter: @autoclosure @Sendable () -> NotificationCenter = .default) {
    // Per the documentation, NotificationCenter is not Sendable
    let notificationCenter = LockIsolated(notificationCenter())
    self.init { name, object, userInfo, _, _ in
      notificationCenter.withValue {
        $0.post(name: name, object: object, userInfo: userInfo)
      }
    } addObserver: { observer, selector, name, object, _, _ in
      notificationCenter.withValue {
        $0.addObserver(observer, selector: selector, name: name, object: object)
      }
    } removeObserver: { observer, name, object, _, _ in
      notificationCenter.withValue {
        $0.removeObserver(observer, name: name, object: object)
      }
    } publisher: { name, object, _, _ in
      notificationCenter.withValue {
        $0.publisher(for: name, object: object).eraseToAnyPublisher()
      }
    }
  }
}

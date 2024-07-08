#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  @preconcurrency import Combine
  import Dependencies
  import Foundation
  import XCTestDynamicOverlay

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
          #"@Dependency(\.notificationCenter.post)"#),
        addObserver: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.notificationCenter.addObserver)"#,
          placeholder: { @Sendable _, _, _, _, _, _ in () }),
        removeObserver: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.notificationCenter.removeObserver)"#),
        publisher: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.notificationCenter.publisher)"#,
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
        @Sendable (AnyObject, Selector, NSNotification.Name?, AnyObject?, StaticString, UInt) ->
          Void
      let _removeObserver:
        @Sendable (AnyObject, NSNotification.Name?, AnyObject?, StaticString, UInt) -> Void
      let _publisher:
        @Sendable (Notification.Name, AnyObject?, StaticString, UInt) -> AnyPublisher<
          Notification, Never
        >

      init(
        @_inheritActorContext post: @escaping @Sendable (
          NSNotification.Name, AnyObject?, [AnyHashable: Any]?, StaticString, UInt
        ) -> Void,
        @_inheritActorContext addObserver: @escaping @Sendable (
          AnyObject, Selector, NSNotification.Name?, AnyObject?, StaticString, UInt
        ) -> Void,
        @_inheritActorContext removeObserver: @escaping @Sendable (
          AnyObject, NSNotification.Name?, AnyObject?, StaticString, UInt
        ) -> Void,
        @_inheritActorContext publisher: @escaping @Sendable (
          Notification.Name, AnyObject?, StaticString, UInt
        ) ->
          AnyPublisher<Notification, Never>
      ) {
        self._post = post
        self._addObserver = addObserver
        self._removeObserver = removeObserver
        self._publisher = publisher
      }
      /// Creates a notification with a given name, sender, and information and posts it to the
      /// notification center.
      public func post(
        name: NSNotification.Name,
        object: AnyObject? = nil,
        userInfo: [AnyHashable: Any]? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
      ) {
        self._post(name, object, userInfo, file, line)
      }

      /// Adds an entry to the notification center to call the provided selector with the
      /// notification.
      public func addObserver(
        _ observer: AnyObject,
        selector: Selector,
        name: NSNotification.Name?,
        object: AnyObject?,
        file: StaticString = #filePath,
        line: UInt = #line
      ) {
        self._addObserver(observer, selector, name, object, file, line)
      }
      /// Removes matching entries from the notification center's dispatch table.
      public func removeObserver(
        _ observer: AnyObject,
        name: NSNotification.Name? = nil,
        object: AnyObject? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
      ) {
        self._removeObserver(observer, name, object, file, line)
      }
      /// Returns a publisher that emits events when broadcasting notifications.
      public func publisher(
        for name: Notification.Name,
        object: AnyObject? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
      ) -> AnyPublisher<
        Notification, Never
      > {
        self._publisher(name, object, file, line)
      }
    }
  }

  extension NotificationCenter.Dependency {
    /// Returns an asynchronous sequence of notifications produced by this center for a given
    /// notification name and optional source object.
    public func notifications(
      named name: Notification.Name,
      object: AnyObject? = nil,
      file: StaticString = #filePath,
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
    /// Creates a new `NotificationCenter.Dependency` from a `NotificationCenter` instance.
    public init(_ notificationCenter: @autoclosure @Sendable () -> NotificationCenter = .default) {
      // NotificationCenter is not Sendable
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
#endif

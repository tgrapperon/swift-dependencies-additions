import Combine
import Dependencies
@_spi(Internals) import DependenciesAdditions
import Foundation
import NotificationCenterDependency

extension Dependency {
  /// A property wrapper that exposes typed and bidirectional `Notification`s, backed by the
  /// `\.notificationCenter` dependency.
  @propertyWrapper
  public struct Notification: Sendable {
    @Dependencies.Dependency(\.notificationCenter) var notificationCenter
    @Dependencies.Dependency(\.self) var dependencies

    let notification: Notifications.NotificationOf<Value>
    let file: StaticString
    let line: UInt

    /// Creates a `Dependency.Notification` property wrapper using a
    /// ``Notifications/NotificationOf`` value.
    /// - Parameters:
    ///   - notification: A fully formed ``Notifications/NotificationOf`` value.
    public init(
      _ notification: Notifications.NotificationOf<Value>,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.notification = notification
      self.file = file
      self.line = line
    }

    /// Creates a `Dependency.Notification` property wrapper using a `KeyPath` from
    /// ``Notifications`` to ``Notifications/NotificationOf`` value, in the same fashion you refer
    /// to `DependencyValues`:
    ///
    /// ```swift
    /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
    /// ```
    /// - Parameters:
    ///   - notification: A fully formed ``Notifications/NotificationOf`` value.
    public init(
      _ notification: KeyPath<Notifications, Notifications.NotificationOf<Value>>,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.notification = Notifications()[keyPath: notification]
      self.file = file
      self.line = line
    }

    /// Creates a `Dependency.Notification` property wrapper using a `Notification.Name`. This
    /// notification forwards untyped `Notification` unconditionally.
    ///
    /// - Parameters:
    ///   - name: The name of the `Notification`.
    ///   - object: The object that sends notifications to the observer.
    public init(
      _ name: Foundation.Notification.Name,
      object: NSObject? = nil,
      file: StaticString = #fileID,
      line: UInt = #line
    ) where Value == Foundation.Notification {
      self.init(
        Notifications.NotificationOf<Value>(
          name,
          object: object,
          file: file,
          line: line
        ),
        file: file,
        line: line
      )
    }

    /// A ``Notifications/StreamOf`` value that can be iterated asynchronously to produce a stream
    /// of typed values.
    public var wrappedValue: Notifications.StreamOf<Value> {
      self.notificationCenter.streamOf(
        self.notification.withContextualDependencies(
          self.dependencies,
          file: file,
          line: line
        ),
        file: file,
        line: line
      )
    }
  }
}

/// A global namespace where you can declare ``NotificationOf`` values as read-only properties.
///
/// You can then use `KeyPath`s of these values with the `@Dependency.Notification` property
/// wrapper.
///
/// ```swift
/// extension Notification {
///   public var userDidTakeScreenshot: NotificationOf<Void> {
///     .init(UIApplication.userDidTakeScreenshotNotification)
///   }
/// }
/// ```
public struct Notifications {}

extension Notifications {
  /// Creates a ``Notifications/NotificationOf`` value that describes a bidirectional and typed
  /// `Notification`.
  ///
  /// If you define these values globally as read-only properties of the ``Notifications`` value,
  /// you can directly refer to it by `KeyPath` when using the `@Dependency.Notification`
  /// property wrapper:
  ///
  /// ```swift
  /// extension Notification {
  ///   public var userDidTakeScreenshot: NotificationOf<Void> {
  ///     .init(UIApplication.userDidTakeScreenshotNotification)
  ///   }
  /// }
  ///
  /// // And then:
  /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
  /// TODO: Expand with a better example of a notification that stores info in its userinfo.
  /// ```
  public struct NotificationOf<Value>: Sendable {
    let name: Notification.Name
    let object: UncheckedSendable<NSObject>?
    let _extract: @Sendable (Notification) -> Value?
    let _embed: @Sendable (Value, inout Notification) -> Void

    private var contextualDependencies: DependencyValues?

    func extract(from notification: Notification) -> Value? {
      @Dependency(\.self) var current
      return withDependencyValues {
        $0 = self.contextualDependencies ?? current
      } operation: {
        _extract(notification)
      }
    }

    func embed(_ value: Value, into notification: inout Notification) {
      @Dependency(\.self) var current
      return withDependencyValues {
        $0 = self.contextualDependencies ?? current
      } operation: {
        _embed(value, &notification)
      }
    }

    var notification: Foundation.Notification {
      .init(name: name, object: object?.wrappedValue)
    }
  }
}

extension Notifications.NotificationOf {
  /// Creates a ``Notifications/NotificationOf`` value that describes a bidirectional and typed
  /// `Notification`.
  ///
  /// If you define these values globally as read-only properties of the ``Notifications`` value,
  /// you can directly refer to it by `KeyPath` when using the `@Dependency.Notification`
  /// property wrapper:
  ///
  /// ```swift
  /// extension Notification {
  ///   public var userDidTakeScreenshot: NotificationOf<Void> {
  ///     .init(UIApplication.userDidTakeScreenshotNotification)
  ///   }
  /// }
  ///
  /// // And then:
  /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
  /// ```
  ///
  /// - Parameters:
  ///   - name: The name of the `Notification`.
  ///   - object: The object that sends notifications to the observer.
  ///   - extract: A closure that tranforms the `Notification` into a typed `Value`, or `nil` to
  ///   filter out this event.
  ///   - embed: A closure where you can reinject a provided `Value` into a `Notification`.
  public init(
    _ name: Notification.Name,
    object: NSObject? = nil,
    extract: @escaping @Sendable (Notification) -> Value? = { $0 },
    embed: @escaping @Sendable (Value, inout Notification) -> Void = {
      if let value = $0 as? Notification, value.name == $1.name { $1 = value }
    },
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.name = name
    self.object = object.map(UncheckedSendable.init(wrappedValue:))
    self._extract = extract
    self._embed = embed
  }

  /// Creates a ``Notifications/NotificationOf`` value that describes a bidirectional
  /// `Notification` of `Void` values.
  ///
  /// If you define these values globally as read-only properties of the ``Notifications`` value,
  /// you can directly refer to it by `KeyPath` when using the `@Dependency.Notification`
  /// property wrapper:
  ///
  /// ```swift
  /// extension Notification {
  ///   public var userDidTakeScreenshot: NotificationOf<Void> {
  ///     .init(UIApplication.userDidTakeScreenshotNotification)
  ///   }
  /// }
  ///
  /// // And then:
  /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
  /// ```
  ///
  /// - Parameters:
  ///   - name: The name of the `Notification`.
  ///   - object: The object that sends notifications to the observer.
  ///   - extract: A closure that tranforms the `Notification` into a typed `Value`, or `nil` to
  ///   filter out this event.
  ///   - embed: A closure where you can reinject a provided `Value` into a `Notification`.
  public init(
    _ name: Notification.Name,
    object: NSObject? = nil,
    file: StaticString = #fileID,
    line: UInt = #line
  ) where Value == Void {
    self.init(
      name,
      object: object,
      extract: { _ in () },
      embed: { _, _ in () },
      file: file,
      line: line
    )
  }

  // TODO: Add map operation?
}

extension Notifications.NotificationOf {
  func withContextualDependencies(
    _ dependencyValues: DependencyValues,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    var contextualized = self
    contextualized.contextualDependencies = dependencyValues
    return contextualized
  }
}

extension Notifications {
  /// An `AsyncSequence` of a ``NotificationOf``'s `Value` that can be enumerated, and to which you
  /// can also post `Value`s
  ///
  /// This `AsyncSequence` can be enumerated by multiple clients, as each notification will be
  /// delivered to all of them.
  public struct StreamOf<Value>: Sendable {
    private let post: @Sendable (Value, StaticString, UInt) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    private let notification: NotificationOf<Value>
    @Dependency(\.notificationCenter) var notificationCenter
    @Dependency(\.self) var dependencies

    init(
      _ notification: NotificationOf<Value>,
      post: @escaping @Sendable (Value, StaticString, UInt) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.notification = notification
      self.post = post
      self.stream = stream
    }

    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    public func post(_ value: Value, file: StaticString = #fileID, line: UInt = #line) {
      self.post(value, file, line)
    }

    /// Returns a new ``Notifications/StreamOf`` where the `DependenciesValues` used to extract or
    /// embed the `Value` are the one from the current context.
    ///
    /// In case you're using local a `@Dependency(\.someDependency)` inside
    /// ``Notifications/NotificationOf/init(_:object:extract:embed:file:line:)``'s
    /// `extract` or `embed` closures, the corresponding `DependencyValues`'s are extracted by
    /// default from the context where you declared the `@Dependency.Notification` property wrapper
    /// that this ``Notifications/StreamOf`` was extracted from.
    ///
    /// By calling this method, you generate a new stream where the `DependencyValues` are resolved
    /// using the current context instead.
    ///
    /// For example, if the `extract` closure uses a `@Dependency(\.timeZone) var timeZone`
    /// dependency to generate its value:
    ///
    /// ```swift
    /// @Dependency.Notification(\.timeZoneDidChange) var timeZoneNotification // (context "A")
    ///
    /// Task {
    ///   for await timeZone in timeZoneNotification {
    ///     // `timeZone` was generated using the `\.timeZone` dependency resolved in
    ///     // the context "A"
    ///   }
    /// }
    ///
    /// Task {
    ///   DependencyValue.withValue(\.timeZone, TimeZone(secondsFromGMT: 0)) {
    ///     for await timeZone in timeZoneNotification {
    ///       // `timeZone` was still generated using the `\.timeZone` dependency resolved
    ///       // in the context "A"
    ///     }
    ///   }
    /// }
    ///
    /// Task {
    ///   DependencyValue.withValue(\.timeZone, TimeZone(secondsFromGMT: 0)) { // (context "B")
    ///     for await timeZone in timeZoneNotification.withCurrentDependencyValues() {
    ///       // `timeZone` was generated using the `\.timeZone` dependency resolved in
    ///       // the context "B", that is, using `TimeZone(secondsFromGMT: 0)`.
    ///     }
    ///   }
    /// }
    /// ```
    ///
    public func withCurrentDependencyValues(file: StaticString = #fileID, line: UInt = #line)
      -> Self
    {
      @Dependency(\.self) var dependencies;
      let updatedNotification = self.notification.withContextualDependencies(
        dependencies,
        file: file,
        line: line
      )
      return self.notificationCenter.streamOf(updatedNotification, file: file, line: line)
    }
  }
}

extension Notifications.StreamOf: AsyncSequence {
  public typealias AsyncIterator = AsyncStream<Value>.Iterator
  public typealias Element = Value

  public func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
    self.stream().makeAsyncIterator()
  }
}

extension Notifications.StreamOf where Value: Sendable {
  @MainActor
  public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Value>, on object: Root)
    -> AnyCancellable
  {
    self.mainActorPublisher().assign(to: keyPath, on: object)
  }

  @MainActor
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  public func assign(to published: inout Published<Value>.Publisher) {
    self.mainActorPublisher().assign(to: &published)
  }
}

extension NotificationCenter.Dependency {
  func streamOf<Value>(
    _ notification: Notifications.NotificationOf<Value>, file: StaticString, line: UInt
  )
    -> Notifications.StreamOf<Value>
  {
    Notifications.StreamOf<Value>(notification) { value, file, line in
      var nsNotification = notification.notification
      notification.embed(value, into: &nsNotification)
      self.post(
        name: nsNotification.name,
        object: nsNotification.object as AnyObject,
        userInfo: nsNotification.userInfo,
        file: file,
        line: line
      )
    } stream: {
      self.notifications(
        named: notification.name,
        object: notification.object?.wrappedValue,
        file: file,
        line: line
      )
      .compactMap {
        notification.extract(from: $0)
      }
      .eraseToStream()
    }
  }
}

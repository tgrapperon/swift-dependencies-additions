import Combine
import Dependencies
@_spi(Internals) import DependenciesAdditions
import Foundation
import NotificationCenterDependency

extension Dependency {
  /// A property wrapper that exposes typed and bidirectional `Notification`s, backed by the
  /// `\.notificationCenter` dependency.
  @propertyWrapper
  public struct Notification<Stream>: Sendable where Value: Sendable {
    // We need to do a little mental gymnastic, as Value == NotificationOf<T>
    @Dependencies.Dependency(\.notificationCenter) var notificationCenter
    @Dependencies.Dependency(\.self) var dependencies

    let notification: Value
    let file: StaticString
    let line: UInt
    let stream:
      @Sendable (Value, NotificationCenter.Dependency, DependencyValues, StaticString, UInt) ->
        Stream

    /// A ``Notifications/StreamOf`` value that can be iterated asynchronously to produce a stream
    /// of typed values.
    public var wrappedValue: Stream {
      self.stream(
        self.notification, self.notificationCenter, self.dependencies, self.file, self.line)
    }
  }
}

extension Dependency.Notification {
  /// Creates a `Dependency.Notification` property wrapper using a
  /// ``Notifications/NotificationOf`` value.
  /// - Parameters:
  ///   - notification: A fully formed ``Notifications/NotificationOf`` value.
  public init<T>(
    _ notification: Notifications.NotificationOf<T>,
    file: StaticString = #fileID,
    line: UInt = #line
  ) where Value == Notifications.NotificationOf<T>, Stream == Notifications.StreamOf<T> {
    self.notification = notification
    self.file = file
    self.line = line
    self.stream = {
      $0.stream(
        notificationCenter: $1,
        contextualDependencies: $2,
        file: $3,
        line: $4
      )
    }
  }

  /// Creates a `Dependency.Notification` property wrapper using a
  /// ``Notifications/MainActorNotificationOf`` value.
  /// - Parameters:
  ///   - notification: A fully formed ``Notifications/MainActorNotificationOf`` value.
  public init<T>(
    _ notification: Notifications.MainActorNotificationOf<T>,
    file: StaticString = #fileID,
    line: UInt = #line
  )
  where
    Value == Notifications.MainActorNotificationOf<T>, Stream == Notifications.MainActorStreamOf<T>
  {
    self.notification = notification
    self.file = file
    self.line = line
    self.stream = {
      $0.stream(
        notificationCenter: $1,
        contextualDependencies: $2,
        file: $3,
        line: $4
      )
    }
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
  public init<T>(
    _ notification: KeyPath<Notifications, Notifications.NotificationOf<T>>,
    file: StaticString = #fileID,
    line: UInt = #line
  ) where Value == Notifications.NotificationOf<T>, Stream == Notifications.StreamOf<T> {
    self.notification = Notifications()[keyPath: notification]
    self.file = file
    self.line = line
    self.stream = {
      $0.stream(
        notificationCenter: $1,
        contextualDependencies: $2,
        file: $3,
        line: $4
      )
    }
  }

  /// Creates a `Dependency.Notification` property wrapper using a `KeyPath` from
  /// ``Notifications`` to ``Notifications/MainActorNotificationOf`` value, in the same fashion you refer
  /// to `DependencyValues`:
  ///
  /// ```swift
  /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
  /// ```
  /// - Parameters:
  ///   - notification: A fully formed ``Notifications/MainActorNotificationOf`` value.
  public init<T>(
    _ notification: KeyPath<Notifications, Notifications.MainActorNotificationOf<T>>,
    file: StaticString = #fileID,
    line: UInt = #line
  )
  where
    Value == Notifications.MainActorNotificationOf<T>, Stream == Notifications.MainActorStreamOf<T>
  {
    self.notification = Notifications()[keyPath: notification]
    self.file = file
    self.line = line
    self.stream = {
      $0.stream(
        notificationCenter: $1,
        contextualDependencies: $2,
        file: $3,
        line: $4
      )
    }
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
  )
  where
    Value == Notifications.NotificationOf<Foundation.Notification>,
    Stream == Notifications.StreamOf<Foundation.Notification>
  {
    self.init(
      Notifications.NotificationOf<Foundation.Notification>(
        name,
        object: object,
        file: file,
        line: line
      ),
      file: file,
      line: line
    )
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
    let _extract: @Sendable (Notification) async -> Value?
    let _embed: @Sendable (Value, inout Notification) async -> Void

    private var contextualDependencies: DependencyValues?

    func extract(from notification: Notification) async -> Value? {
      @Dependency(\.self) var current
      return await withDependencyValues {
        $0 = self.contextualDependencies ?? current
      } operation: {
        await _extract(notification)
      }
    }

    func embed(_ value: Value, into notification: inout Notification) async {
      @Dependency(\.self) var current
      return await withDependencyValues {
        $0 = self.contextualDependencies ?? current
      } operation: {
        await _embed(value, &notification)
      }
    }

    var notification: Foundation.Notification {
      .init(name: name, object: object?.wrappedValue)
    }

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
}

extension Notifications {
  public struct MainActorNotificationOf<Value: Sendable>: Sendable {
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
    @_inheritActorContext extract: @escaping @Sendable (Notification) async -> Value? = { $0 },
    @_inheritActorContext embed: @escaping @Sendable (Value, inout Notification) async -> Void = {
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

extension Notifications.MainActorNotificationOf {
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
  @MainActor
  public init(
    _ name: Notification.Name,
    object: NSObject? = nil,
    @_inheritActorContext extract: @escaping @Sendable (Notification) -> Value? = { $0 },
    @_inheritActorContext embed: @escaping @Sendable (Value, inout Notification) -> Void = {
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
  @MainActor
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

extension Notifications {
  /// An `AsyncSequence` of a ``NotificationOf``'s `Value` that can be enumerated, and to which you
  /// can also post `Value`s
  ///
  /// This `AsyncSequence` can be enumerated by multiple clients, as each notification will be
  /// delivered to all of them.
  public struct StreamOf<Value>: Sendable {
    private let post: @Sendable (Value, StaticString, UInt) async -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    private let notification: NotificationOf<Value>
    @Dependency(\.notificationCenter) var notificationCenter
    @Dependency(\.self) var dependencies

    init(
      _ notification: NotificationOf<Value>,
      post: @escaping @Sendable (Value, StaticString, UInt) async -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.notification = notification
      self.post = post
      self.stream = stream
    }

    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    public func post(_ value: Value, file: StaticString = #fileID, line: UInt = #line) async {
      await self.post(value, file, line)
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
      @Dependency(\.self) var dependencies
      return self.notification.stream(
        notificationCenter: self.notificationCenter,
        contextualDependencies: dependencies,
        file: file,
        line: line
      )
    }
  }
}

extension Notifications {
  /// An `AsyncSequence` of a ``NotificationOf``'s `Value` that can be enumerated, and to which you
  /// can also post `Value`s
  ///
  /// This `AsyncSequence` can be enumerated by multiple clients, as each notification will be
  /// delivered to all of them.
  public struct MainActorStreamOf<Value: Sendable>: Sendable {
    private let post: @MainActor @Sendable (Value, StaticString, UInt) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    private let notification: MainActorNotificationOf<Value>
    @Dependency(\.notificationCenter) var notificationCenter
    @Dependency(\.self) var dependencies

    init(
      _ notification: MainActorNotificationOf<Value>,
      post: @escaping @MainActor @Sendable (Value, StaticString, UInt) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.notification = notification
      self.post = post
      self.stream = stream
    }

    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    @MainActor
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
      @Dependency(\.self) var dependencies
      return self.notification.stream(
        notificationCenter: self.notificationCenter,
        contextualDependencies: dependencies,
        file: file,
        line: line
      )
    }
  }
}

public protocol NotificationStream: AsyncSequence & Sendable
where AsyncIterator == AsyncStream<Element>.Iterator {}

extension Notifications.StreamOf: NotificationStream {
  public typealias Element = Value

  public func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
    self.stream().makeAsyncIterator()
  }
}

extension Notifications.MainActorStreamOf: NotificationStream {
  public typealias Element = Value

  public func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
    self.stream().makeAsyncIterator()
  }
}

extension NotificationStream where Self: AsyncSequence, Self.Element: Sendable {
  @MainActor
  public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root)
    -> AnyCancellable
  {
    self.mainActorPublisher().assign(to: keyPath, on: object)
  }

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @MainActor
  public func assign(to published: inout Published<Element>.Publisher) {
    self.mainActorPublisher().assign(to: &published)
  }

  @MainActor
  public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element?>, on object: Root)
    -> AnyCancellable
  {
    self.mainActorPublisher().map(Optional.some).assign(to: keyPath, on: object)
  }

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @MainActor
  public func assign(to published: inout Published<Element?>.Publisher) {
    self.mainActorPublisher().map(Optional.some).assign(to: &published)
  }
}

extension Notifications.NotificationOf {
  public func stream(
    notificationCenter: NotificationCenter.Dependency, contextualDependencies: DependencyValues,
    file: StaticString, line: UInt
  ) -> Notifications.StreamOf<Value> {
    let notification = self.withContextualDependencies(
      contextualDependencies,
      file: file,
      line: line
    )
    return Notifications.StreamOf<Value>(notification) { value, file, line in
      var nsNotification = notification.notification
      await notification.embed(value, into: &nsNotification)
      notificationCenter.post(
        name: nsNotification.name,
        object: nsNotification.object as AnyObject,
        userInfo: nsNotification.userInfo,
        file: file,
        line: line
      )
    } stream: {
      notificationCenter.notifications(
        named: notification.name,
        object: notification.object?.wrappedValue,
        file: file,
        line: line
      )
      .compactMap {
        await notification.extract(from: $0)
      }
      .eraseToStream()
    }
  }
}

extension Notifications.MainActorNotificationOf {
  func stream(
    notificationCenter: NotificationCenter.Dependency, contextualDependencies: DependencyValues,
    file: StaticString, line: UInt
  ) -> Notifications.MainActorStreamOf<Value> {
    let notification = self.withContextualDependencies(
      contextualDependencies,
      file: file,
      line: line
    )
    return Notifications.MainActorStreamOf(notification) { value, file, line in
      var nsNotification = notification.notification
      notification.embed(value, into: &nsNotification)
      notificationCenter.post(
        name: nsNotification.name,
        object: nsNotification.object as AnyObject,
        userInfo: nsNotification.userInfo,
        file: file,
        line: line
      )
    } stream: {
      notificationCenter.notifications(
        named: notification.name,
        object: notification.object?.wrappedValue,
        file: file,
        line: line
      )
      .compactMap {
        let n = UncheckedSendable($0)
        return await MainActor.run {
          notification.extract(from: n.wrappedValue)
        }
      }
      .eraseToStream()
    }
  }
}

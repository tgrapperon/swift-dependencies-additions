#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  @_exported import Dependencies
  @_spi(Internals) @_exported import DependenciesAdditionsBasics
  import Foundation
  import NotificationCenterDependency

  // TODO: Rework documentations example to be more illustrative of each configuraiton.

  extension Dependency {
    /// A property wrapper that exposes typed and bidirectional `Notification`s, backed by the
    /// `\.notificationCenter` dependency.
    @propertyWrapper
    public struct Notification: Sendable where Value: NotificationStream {
      @Dependencies.Dependency(\.notificationCenter) var notificationCenter
      @Dependencies.Dependency(\.self) var dependencies
      let stream: @Sendable (NotificationCenter.Dependency, DependencyValues) -> Value

      /// A ``Notifications/StreamOf`` value that can be iterated asynchronously to produce a stream
      /// of typed values.
      public var wrappedValue: Value {
        self.stream(self.notificationCenter, self.dependencies)
      }
    }
  }

  extension Dependency.Notification {
    /// Creates a `Dependency.Notification` property wrapper using a
    /// ``Notifications/NotificationOf`` value.
    /// - Parameters:
    ///   - notification: A fully formed ``Notifications/NotificationOf`` value.
    public init<Tag, T>(
      _ notification: Notifications._TaggedNotificationOf<Tag, T>,
      file: StaticString = #filePath,
      line: UInt = #line
    ) where Value == Notifications.StreamOf<Tag, T> {
      self.stream = {
        notification.stream(
          notificationCenter: $0,
          contextualDependencies: $1,
          file: file,
          line: line
        )
      }
    }

    /// Creates a `Dependency.Notification` property wrapper using a
    /// ``Notifications/MainActorNotificationOf`` value.
    /// - Parameters:
    ///   - notification: A fully formed ``Notifications/MainActorNotificationOf`` value.
    public init<Tag, T>(
      _ notification: Notifications._TaggedMainActorNotificationOf<Tag, T>,
      file: StaticString = #filePath,
      line: UInt = #line
    )
    where
      Value == Notifications.MainActorStreamOf<Tag, T>
    {
      self.stream = {
        notification.stream(
          notificationCenter: $0,
          contextualDependencies: $1,
          file: file,
          line: line
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
    public init<Tag, T>(
      _ notification: KeyPath<Notifications, Notifications._TaggedNotificationOf<Tag, T>>,
      file: StaticString = #filePath,
      line: UInt = #line
    ) where Value == Notifications.StreamOf<Tag, T> {
      let notification = Notifications()[keyPath: notification]
      self.stream = {
        notification.stream(
          notificationCenter: $0,
          contextualDependencies: $1,
          file: file,
          line: line
        )
      }
    }

    /// Creates a `Dependency.Notification` property wrapper using a `KeyPath` from
    /// ``Notifications`` to ``Notifications/MainActorNotificationOf`` value, in the same fashion you
    /// refer to `DependencyValues`:
    ///
    /// ```swift
    /// @Dependency.Notification(\.userDidTakeScreenshot) var screenshots
    /// ```
    /// - Parameters:
    ///   - notification: A fully formed ``Notifications/MainActorNotificationOf`` value.
    public init<Tag, T>(
      _ notification: KeyPath<Notifications, Notifications._TaggedMainActorNotificationOf<Tag, T>>,
      file: StaticString = #filePath,
      line: UInt = #line
    )
    where
      Value == Notifications.MainActorStreamOf<Tag, T>
    {
      let notification = Notifications()[keyPath: notification]
      self.stream = {
        notification.stream(
          notificationCenter: $0,
          contextualDependencies: $1,
          file: file,
          line: line
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
      file: StaticString = #filePath,
      line: UInt = #line
    )
    where
      Value == Notifications.StreamOf<Notifications.System, Foundation.Notification>
    {
      self.init(
        Notifications._TaggedNotificationOf<Notifications.System, Foundation.Notification>(
          name,
          object: object,
          placeholder: nil,
          file: file,
          line: line
        )
      )
    }
  }

  /// A global namespace where you can declare ``NotificationOf`` and ``MainActorNotificationOf``
  /// values as read-only properties.
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
    public struct _TaggedNotificationOf<Tag, Value>: Sendable {
      let name: Notification.Name
      let object: UncheckedSendable<NSObject>?
      let _extract: @Sendable (Notification) async -> Value?
      let _embed: @Sendable (Value, inout Notification) async -> Void
      let _placeholder: (@Sendable () -> Value)?
      var contextualDependencies: DependencyValues?

      func extract(from notification: Notification) async -> Value? {
        @Dependency(\.self) var current
        return await withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          await _extract(notification)
        }
      }

      func embed(_ value: Value, into notification: inout Notification) async {
        @Dependency(\.self) var current
        return await withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          await _embed(value, &notification)
        }
      }

      func placeholder() -> Value? {
        guard let _placeholder else { return nil }
        @Dependency(\.self) var current
        return withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          _placeholder()
        }
      }

      var notification: Foundation.Notification {
        .init(name: name, object: object?.wrappedValue)
      }
    }
  }

  extension Notifications {
    public struct _TaggedMainActorNotificationOf<Tag, Value: Sendable>: Sendable {
      let name: Notification.Name
      let object: UncheckedSendable<NSObject>?
      let _extract: @Sendable (Notification) -> Value?
      let _embed: @Sendable (Value, inout Notification) -> Void
      let _placeholder: (@Sendable () -> Value)?

      var contextualDependencies: DependencyValues?

      @MainActor
      func extract(from notification: Notification) -> Value? {
        @Dependency(\.self) var current
        return withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          _extract(notification)
        }
      }
      @MainActor
      func embed(_ value: Value, into notification: inout Notification) {
        @Dependency(\.self) var current
        return withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          _embed(value, &notification)
        }
      }

      @MainActor
      func placeholder() -> Value? {
        guard let _placeholder else { return nil }
        @Dependency(\.self) var current
        return withDependencies {
          $0 = self.contextualDependencies ?? current
        } operation: {
          _placeholder()
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
      @_inheritActorContext extract: @escaping @Sendable (Notification) async -> Value? = { $0 },
      @_inheritActorContext embed: @escaping @Sendable (Value, inout Notification) async -> Void = {
        if let value = $0 as? Notification, value.name == $1.name { $1 = value }
      },
      @_inheritActorContext placeholder: (@Sendable () -> Value)? = nil,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      self.name = name
      self.object = object.map(UncheckedSendable.init(wrappedValue:))
      self._extract = extract
      self._placeholder = placeholder
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
      file: StaticString = #filePath,
      line: UInt = #line
    ) where Value == Void {
      self.init(
        name,
        object: object,
        extract: { _ in () },
        embed: { _, _ in () },
        placeholder: nil,
        file: file,
        line: line
      )
    }

    // TODO: Add map operation?
  }

  extension Notifications.MainActorNotificationOf {
    /// Creates a ``Notifications/MainActorNotificationOf`` value that describes a bidirectional and
    /// typed `Notification` that are received and processed on the `MainActor`.
    ///
    /// If you define these values globally as read-only properties of the ``Notifications`` value,
    /// you can directly refer to it by `KeyPath` when using the `@Dependency.Notification`
    /// property wrapper:
    ///
    /// ```swift
    /// extension Notification {
    ///   @MainActor
    ///   public var userDidTakeScreenshot: MainActorNotificationOf<Void> {
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
      @_inheritActorContext placeholder: (@Sendable () -> Value)? = nil,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      self.name = name
      self.object = object.map(UncheckedSendable.init(wrappedValue:))
      self._extract = extract
      self._embed = embed
      self._placeholder = placeholder
    }

    /// Creates a ``Notifications/MainActorNotificationOf`` value that describes a bidirectional
    /// `Notification` of `Void` values.
    ///
    /// If you define these values globally as read-only properties of the ``Notifications`` value,
    /// you can directly refer to it by `KeyPath` when using the `@Dependency.Notification`
    /// property wrapper:
    ///
    /// ```swift
    /// extension Notification {
    ///   @MainActor
    ///   public var userDidTakeScreenshot: MainActorNotificationOf<Void> {
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
      file: StaticString = #filePath,
      line: UInt = #line
    ) where Value == Void {
      self.init(
        name,
        object: object,
        extract: { _ in () },
        embed: { _, _ in () },
        placeholder: nil,
        file: file,
        line: line
      )
    }
  }

  public protocol NotificationStream: BroadcastableAsyncSequence & Sendable {}

  extension Notifications {
    /// An `AsyncSequence` of a ``NotificationOf``'s `Value` that can be enumerated, and to which you
    /// can also post `Value`s
    ///
    /// This `AsyncSequence` can be enumerated by multiple clients, as each notification will be
    /// delivered to all of them.
    public struct StreamOf<Tag, Value>: Sendable {
      private let post: @Sendable (Value, StaticString, UInt) async -> Void
      private let stream: @Sendable () -> AsyncStream<Value>
      private let notification: _TaggedNotificationOf<Tag, Value>
      @Dependency(\.notificationCenter) var notificationCenter
      @Dependency(\.self) var dependencies

      init(
        _ notification: _TaggedNotificationOf<Tag, Value>,
        post: @escaping @Sendable (Value, StaticString, UInt) async -> Void,
        stream: @escaping @Sendable () -> AsyncStream<Value>
      ) {
        self.notification = notification
        self.post = post
        self.stream = stream
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
      ///     for await timeZone in timeZoneNotification.withCurrentDependencies() {
      ///       // `timeZone` was generated using the `\.timeZone` dependency resolved in
      ///       // the context "B", that is, using `TimeZone(secondsFromGMT: 0)`.
      ///     }
      ///   }
      /// }
      /// ```
      public func withCurrentDependencies(file: StaticString = #filePath, line: UInt = #line)
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

  extension Notifications.StreamOf where Tag == Notifications.User {
    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    public func post(_ value: Value, file: StaticString = #filePath, line: UInt = #line) async {
      await self.post(value, file, line)
    }
  }

  extension Notifications.StreamOf {
    /// Access testing functions
    public var testing: Testing {
      .init(stream: self)
    }
    public struct Testing: Sendable {
      let stream: Notifications.StreamOf<Tag, Value>
      /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
      public func post(_ value: Value, file: StaticString = #filePath, line: UInt = #line) async {
        await stream.post(value, file, line)
      }
    }
  }

  extension Notifications {
    /// An `AsyncSequence` of a ``MainActorStreamOf``'s `Value` that can be enumerated, and to which
    /// you can also post `Value`s
    ///
    /// This `AsyncSequence` can be enumerated by multiple clients, as each notification will be
    /// delivered to all of them.
    public struct MainActorStreamOf<Tag, Value: Sendable>: Sendable {
      private let post: @MainActor @Sendable (Value, StaticString, UInt) -> Void
      private let stream: @MainActor @Sendable () -> AsyncStream<Value>
      private let notification: _TaggedMainActorNotificationOf<Tag, Value>
      @Dependency(\.notificationCenter) var notificationCenter
      @Dependency(\.self) var dependencies

      init(
        _ notification: _TaggedMainActorNotificationOf<Tag, Value>,
        post: @escaping @MainActor @Sendable (Value, StaticString, UInt) -> Void,
        stream: @escaping @MainActor @Sendable () -> AsyncStream<Value>
      ) {
        self.notification = notification
        self.post = post
        self.stream = stream
      }

      /// Returns a new ``Notifications/MainActorStreamOf`` where the `DependenciesValues` used to extract or
      /// embed the `Value` are the one from the current context.
      ///
      /// In case you're using local a `@Dependency(\.someDependency)` inside
      /// ``Notifications/MainActorNotificationOf/init(_:object:file:line:)``'s
      /// `extract` or `embed` closures, the corresponding `DependencyValues`'s are extracted by
      /// default from the context where you declared the `@Dependency.Notification` property wrapper
      /// that this ``Notifications/MainActorStreamOf`` was extracted from.
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
      ///     for await timeZone in timeZoneNotification.withCurrentDependencies() {
      ///       // `timeZone` was generated using the `\.timeZone` dependency resolved in
      ///       // the context "B", that is, using `TimeZone(secondsFromGMT: 0)`.
      ///     }
      ///   }
      /// }
      /// ```
      public func withCurrentDependencies(file: StaticString = #filePath, line: UInt = #line)
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

  extension Notifications.MainActorStreamOf where Tag == Notifications.User {
    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    @MainActor
    public func post(_ value: Value, file: StaticString = #filePath, line: UInt = #line) {
      self.post(value, file, line)
    }
  }

  extension Notifications.MainActorStreamOf {
    /// Access testing functions
    public var testing: Testing {
      .init(stream: self)
    }
    public struct Testing: Sendable {
      let stream: Notifications.MainActorStreamOf<Tag, Value>
      /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
      @MainActor
      public func post(_ value: Value, file: StaticString = #filePath, line: UInt = #line) {
        stream.post(value, file, line)
      }
    }
  }

  extension Notifications.StreamOf: NotificationStream {
    public typealias AsyncIterator = AsyncStream<Value>.Iterator
    public typealias Element = Value

    public func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
      self.stream().makeAsyncIterator()
    }
  }

  extension Notifications.MainActorStreamOf: NotificationStream {
    public typealias AsyncIterator = AsyncStream<Value>.Iterator
    public typealias Element = Value

    public func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
      AsyncStream {
        await MainActor.run {
          self.stream()
        }
      }.makeAsyncIterator()
    }
  }

  extension Notifications.NotificationOf {
    func stream(
      notificationCenter: NotificationCenter.Dependency, contextualDependencies: DependencyValues,
      file: StaticString, line: UInt
    ) -> Notifications.StreamOf<Tag, Value> {
      var notification = self
      notification.contextualDependencies = contextualDependencies
      return Notifications.StreamOf(notification) { [notification] value, file, line in
        var nsNotification = notification.notification
        await notification.embed(value, into: &nsNotification)
        notificationCenter.post(
          name: nsNotification.name,
          object: nsNotification.object as AnyObject,
          userInfo: nsNotification.userInfo,
          file: file,
          line: line
        )
      } stream: { [notification] in
        AsyncStream(
          first: notification.placeholder,
          then: notificationCenter.notifications(
            named: notification.name,
            object: notification.object?.wrappedValue,
            file: file,
            line: line
          )
          .compactMap {
            await notification.extract(from: $0)
          }
        )
      }
    }
  }

  extension Notifications.MainActorNotificationOf {
    func stream(
      notificationCenter: NotificationCenter.Dependency, contextualDependencies: DependencyValues,
      file: StaticString, line: UInt
    ) -> Notifications.MainActorStreamOf<Tag, Value> {
      var notification = self
      notification.contextualDependencies = contextualDependencies
      return Notifications.MainActorStreamOf(notification) { [notification] value, file, line in
        var nsNotification = notification.notification
        notification.embed(value, into: &nsNotification)
        notificationCenter.post(
          name: nsNotification.name,
          object: nsNotification.object as AnyObject,
          userInfo: nsNotification.userInfo,
          file: file,
          line: line
        )
      } stream: { [notification] in
        AsyncStream(
          first: notification.placeholder,
          then:
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
        )
      }
    }
  }

  extension AsyncStream {
    init<Base: AsyncSequence>(
      @_inheritActorContext first prefix: @escaping () async -> Base.Element?,
      then sequence: Base
    )
    where Base.Element == Element {
      var didSendPrefix: Bool = false
      var iterator: Base.AsyncIterator?
      self.init(unfolding: {
        defer { didSendPrefix = true }
        if !didSendPrefix, let prefix = await prefix() {
          return prefix
        }
        if iterator == nil {
          iterator = sequence.makeAsyncIterator()
        }
        return try? await iterator?.next()
      })
    }
  }
#endif

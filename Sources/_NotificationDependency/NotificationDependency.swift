import Dependencies
import Foundation
import PathDependency

extension Dependency {
  @propertyWrapper
  public struct Notification: Sendable {
    @Dependencies.Dependency(\.notificationCenter) var notificationCenter
    @Dependencies.Dependency(\.path) var path
    @Dependencies.Dependency(\.self) var dependencies

    let notification: Notifications.NotificationOf<Value>
    let file: StaticString
    let line: UInt
    
    public init(
      _ notification: Notifications.NotificationOf<Value>,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.notification = notification
      self.file = file
      self.line = line
    }

    public init(
      _ notification: KeyPath<Notifications, Notifications.NotificationOf<Value>>,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.notification = Notifications()[keyPath: notification]
      self.file = file
      self.line = line
    }

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

    public var wrappedValue: Notifications.StreamOf<Value> {
      self.notificationCenter.stream(
        DependencyValues.withValue(\.path, self.path) {
          self.notification.withContextualDependencies(
            self.dependencies,
            file: file,
            line: line
          )
        }
      )
    }
  }
}



public struct Notifications {}

extension Notifications {
  public struct NotificationOf<Value>: Sendable {
    private(set) var id: ID
    let name: Notification.Name
    let object: UncheckedSendable<NSObject>?
    let _extract: @Sendable (Notification) throws -> Value
    let _embed: @Sendable (Value, inout Notification) -> Void
    
    private var contextualDependencies: DependencyValues?
    
    func extract(from notification: Notification) throws -> Value {
      @Dependency(\.self) var current;
      return try DependencyValues.withValue(\.self, contextualDependencies ?? current) {
        try _extract(notification)
      }
    }
    
    func embed(_ value: Value, into notification: inout Notification) -> Void {
      @Dependency(\.self) var current;
      return DependencyValues.withValue(\.self, contextualDependencies ?? current) {
        _embed(value, &notification)
      }
    }
    
    var notification: Foundation.Notification {
      .init(name: name, object: object?.wrappedValue)
    }
  }
}

extension Notifications.NotificationOf {
  
  public init(
    _ name: Notification.Name,
    object: NSObject? = nil,
    extract: @escaping @Sendable (Notification) throws -> Value = { $0 },
    embed: @escaping @Sendable (Value, inout Notification) -> Void = { _, _ in () },
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    @Dependency(\.path) var path;
    
    self.name = name
    self.object = object.map(UncheckedSendable.init(wrappedValue:))
    self._extract = extract
    self._embed = embed
    self.id = .init(
      Value.self,
      name: name,
      object: object,
      path: path,
      file: file,
      line: line
    )
  }
  
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
    @Dependency(\.path) var path

    var contextualized = self
    contextualized.contextualDependencies = dependencyValues
    contextualized.id = Notifications.ID(
      Value.self,
      name: self.name,
      object: self.object?.wrappedValue,
      path: path,
      file: file,
      line: line
    )
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
    private let post: @Sendable (Value) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    private let notification: NotificationOf<Value>
    @Dependency(\.notificationCenter) var notificationCenter
    @Dependency(\.self) var dependencies
    
    init(
      _ notification: NotificationOf<Value>,
      post: @escaping @Sendable (Value) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.notification = notification
      self.post = post
      self.stream = stream
    }

    /// Embeds a `Value` in a `Notification` that is then posted to the `NotificationCenter`.
    public func post(_ value: Value) {
      self.post(value)
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
    public func withCurrentDependencyValues(file: StaticString = #file, line: UInt = #line) -> Self {
      let updatedNotification = DependencyValues.withValue(
        \.path, self.notification.id.path
      ) {
        self.notification.withContextualDependencies(
          self.dependencies,
          file: file,
          line: line
        )
      }
      return self.notificationCenter.stream(updatedNotification)
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

extension Notifications {
  struct ID: Hashable, Sendable {
    let name: Notification.Name
    let object: ObjectIdentifier?
    let valueType: ObjectIdentifier
    let path: Path
    let file: String
    let line: UInt
    
    init<V>(
      _ value: V.Type,
      name: Notification.Name,
      object: NSObject?,
      path: Path,
      file: StaticString,
      line: UInt
    ) {
      self.name = name
      self.object = object.map(ObjectIdentifier.init)
      self.valueType = ObjectIdentifier(V.self)
      self.path = path
      self.file = file.description
      self.line = line
    }
  }
}

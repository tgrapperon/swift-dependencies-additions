import Dependencies
import Foundation
@_spi(Internal) import DependenciesAdditions
import PathDependency

extension Dependency {
  @propertyWrapper
  public struct Notification: Sendable {
    @Dependencies.Dependency(\.notifications) var notificationCenter
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
      self.notificationCenter[
        DependencyValues.withValue(\.path, self.path) {
          self.notification.operatingWithDependencyValues(
            self.dependencies,
            file: file,
            line: line
          )
        }
      ]
    }
  }
}

extension DependencyValues {
  public var notifications: any NotificationCenterProtocol {
    get { self[NotificationCenterKey.self] }
    set { self[NotificationCenterKey.self] = newValue }
  }
}

enum NotificationCenterKey: DependencyKey {
  static var liveValue: any NotificationCenterProtocol { .default }
  static var testValue: NotificationCenterProtocol {
    XCTFail(#"Unimplemented: @Dependency(\.notifications)"#)
    return .default
  }
}

public struct Notifications {}

extension Notifications {
  public struct NotificationOf<Value>: Sendable, Identifiable {
    public let id: ID
    let name: Notification.Name
    let object: UncheckedSendable<NSObject>?
    let extract: @Sendable (Notification) throws -> Value
    let embed: @Sendable (Value, inout Notification) -> Void
    
    var notification: Foundation.Notification {
      .init(name: name, object: object?.wrappedValue)
    }
  }
}

extension NotificationCenterProtocol {
  func stream<Value>(notification: Notifications.NotificationOf<Value>) -> Notifications.StreamOf<Value> {
    fatalError()
//    self[notification]
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
    self.extract = extract
    self.embed = embed
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
    @Dependency(\.path) var path;
    
    self.name = name
    self.object = object.map(UncheckedSendable.init(wrappedValue:))
    self.extract = { _ in () }
    self.embed = { _, _ in () }
    self.id = .init(
      Value.self,
      name: name,
      object: object,
      path: path,
      file: file,
      line: line
    )
  }
  
  // TODO: Add map operation?
}

extension Notifications.NotificationOf {
  func operatingWithDependencyValues(
    _ dependencyValues: DependencyValues,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    .init(
      self.name,
      object: self.object?.wrappedValue,
      extract: { notification in
       try DependencyValues.withValue(\.self, dependencyValues) {
         try self.extract(notification)
        }
      },
      embed: { value, notification in
        DependencyValues.withValue(\.self, dependencyValues) {
          self.embed(value, &notification)
         }
      },
      file: file,
      line: line
    )
  }
}


extension Notifications {
//  public struct NotificationOf<Value>: Hashable, Sendable {
//
//    let name: Notification.Name
//    let object: UncheckedSendable<NSObject>?
//    let transform: @Sendable (Notification) throws -> Value
//    let notify: (@Sendable (Value) -> Notification?)?
//
//    let id: ID
//
//    public init(
//      _ name: Notification.Name,
//      object: NSObject? = nil,
//      transform: @escaping @Sendable (Notification) throws -> Value = { $0 },
//      notify: (@Sendable (Value) -> Notification?)? = nil,
//      file: String = #fileID,
//      line: UInt = #line
//    ) {
////      @Dependency(\.path) var path;
//      @Dependency(\.self) var dependencies
//
//      self.name = name
//      self.object = object.map(UncheckedSendable.init(wrappedValue:))
//      self.transform = transform
//      self.notify = notify
//      self.id = .init(
//        Value.self,
//        name: name,
//        object: object,
//        path: dependencies.path,
//        file: file,
//        line: line
//      )
//    }
//
//
//
//
//
//    @MainActor
//    public init(
//      _ name: Notification.Name,
//      object: NSObject? = nil,
//      file: StaticString = #fileID,
//      line: UInt = #line
//    ) where Value == Void {
//      @Dependency(\.path) var path;
//
//      let object = object.map(UncheckedSendable.init(wrappedValue:))
//      self.name = name
//      self.object = object
//      self.transform = { _ in () }
//      self.notify = { _ in Notification(name: name, object: object?.wrappedValue) }
//      self.id = .init(
//        Void.self,
//        name: name,
//        object: object?.wrappedValue,
//        path: path,
//        file: file.description,
//        line: line
//      )
//    }
//
//    func updated(
//      with values: DependencyValues,
//      path: Path,
//      file: StaticString,
//      line: UInt
//    ) -> Self {
//      DependencyValues.withValue(\.path, path) {
//        NotificationOf(
//          self.name,
//          object: self.object?.value,
//          transform: { notification in
//            try DependencyValues.withValue(\.self, values) {
//              try transform(notification)
//            }
//          },
//          notify: self.notify.map { notify in
//            DependencyValues.withValue(\.self, values) {
//              { @Sendable value in notify(value) }
//            }
//          },
//          file: file.description,
//          line: line
//        )
//      }
//    }
//
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//      lhs.id == rhs.id
//    }
//
//    public func hash(into hasher: inout Hasher) {
//      hasher.combine(self.id)
//    }
//
//    var notification: Notification {
//      Notification(name: self.name, object: self.object?.wrappedValue)
//    }
//
//    public func map<T>(
//      transform: @escaping @Sendable (Value) throws -> T,
//      notify: (@Sendable (T) -> Value?)? = nil,
//      file: StaticString = #fileID,
//      line: UInt = #line
//    ) -> NotificationOf<T> {
//      return .init(
//        self.name,
//        object: self.object?.wrappedValue
//      ) {
//        try transform(self.transform($0))
//      } notify: {
//        guard
//          let selfNotify = self.notify,
//          let value = notify?($0)
//        else { return nil }
//        return selfNotify(value)
//      }
//    }
//  }
}

extension Notifications {
  public struct StreamOf<Value>: Sendable {
    private let post: @Sendable (Value) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    init(
      post: @escaping @Sendable (Value) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.post = post
      self.stream = stream
    }

    public func post(_ value: Value) {
      self.post(value)
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
  public struct ID: Hashable, Sendable {
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

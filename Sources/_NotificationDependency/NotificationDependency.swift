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
  func operatingWithDependencyValues(
    _ dependencyValues: DependencyValues,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    return .init(
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
  public struct StreamOf<Value>: Sendable {
    private let post: @Sendable (Value) -> Void
    private let stream: @Sendable () -> AsyncStream<Value>
    private let notification: NotificationOf<Value>
    @Dependency(\.notifications) var notificationCenter
    @Dependency(\.self) var dependencies
    
    init(
      notification: NotificationOf<Value>,
      post: @escaping @Sendable (Value) -> Void,
      stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self.notification = notification
      self.post = post
      self.stream = stream
    }

    public func post(_ value: Value) {
      self.post(value)
    }
    
    public func withLocalDepencies(file: StaticString = #file, line: UInt = #line) -> Self {
      let updatedNotification = DependencyValues.withValue(
        \.path, self.notification.id.path
      ) {
        return notification.operatingWithDependencyValues(
          self.dependencies,
          file: file,
          line: line
        )
      }
      return self.notificationCenter[updatedNotification]
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

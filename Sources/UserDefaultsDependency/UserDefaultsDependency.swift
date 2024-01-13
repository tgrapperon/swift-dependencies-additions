import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation

extension DependencyValues {
  /// A dependency that exposes an ``UserDefaults.Dependency`` value that you can use to read and
  /// write to `UserDefaults`.
  public var userDefaults: UserDefaults.Dependency {
    get { self[UserDefaults.Dependency.self] }
    set { self[UserDefaults.Dependency.self] = newValue }
  }
}

/// A type that abstract `UserDefaults` storage. You can use this type as it, or build your
/// own abstraction on top of it.
extension UserDefaults {
  public struct Dependency: Sendable {
    let _get: @Sendable (_ key: String, _ type: Any.Type) -> (any Sendable)?
    let _set: @Sendable (_ value: (any Sendable)?, _ key: String) -> Void
    let _values: @Sendable (_ key: String, _ type: Any.Type) -> AsyncStream<(any Sendable)?>

    /// Creates an `UserDefaults.Dependency` value that reads and writes values for a given `String`
    /// key.
    init(
      get: @escaping @Sendable (_ key: String, _ type: Any.Type) -> (any Sendable)?,
      set: @escaping @Sendable (_ value: (any Sendable)?, _ key: String) -> Void,
      values: @escaping @Sendable (_ key: String, _ value: Any.Type) -> AsyncStream<(any Sendable)?>
    ) {
      self._get = get
      self._set = set
      self._values = values
    }

    /// Returns the object associated with the specified key.
    @_spi(Internals)
    public func object<T: Sendable>(forKey key: String) -> T? {
      self._get(key, T.self) as? T
    }

    /// Sets the value of the specified default key.
    @_spi(Internals)
    public func set<T: Sendable>(_ value: T?, forKey key: String) {
      self._set(value, key)
    }

    /// An `AsyncStream` of values for a given `key` as they change. The stream produces `nil` if
    /// the value is removed or if no value exists for the given key.
    /// - Parameter key: The key that references this user preference.
    /// - Returns: An `AsyncSequence` of `T?` values, including the initial value.
    @_spi(Internals)
    public func values<T>(forKey key: String) -> AsyncMapSequence<AsyncStream<(any Sendable)?>, T?>
    {
      self._values(key, T.self).map { $0 as? T }
    }
  }
}

extension UserDefaults.Dependency: DependencyKey {
  public static var liveValue: Self { .standard }

  // Should we keep this public?

  /// Creates an `UserDefaults.Dependency` that read and writes to some `UserDefaults` instance.
  /// - Parameter userDefaults: an `UserDefaults` instance to read and write into.
  /// `UserDefaults.standard` is used by default.
  public init(_ userDefaults: UserDefaults = .standard) {
    // According to the documentation, the `UserDefaults` class is thread-safe, so it is safe to
    // wrap into an ``UncheckedSendable`` value.
    let userDefaults = UncheckedSendable(userDefaults)
    self = UserDefaults.Dependency { key, type in
      userDefaults.value.getSendable(forKey: key, as: type)
    } set: {
      userDefaults.value.setSendable($0, forKey: $1)
    } values: { key, type in
      // We use KVO to also get out-of-process changes
      AsyncStream((any Sendable)?.self) { continuation in
        #if canImport(ObjectiveC)
          final class Observer: NSObject, Sendable {
            let key: String
            let type: Any.Type
            let onChange: @Sendable ((any Sendable)?) -> Void
            init(
              key: String,
              type: Any.Type,
              onChange: @escaping @Sendable ((any Sendable)?) -> Void
            ) {
              self.key = key
              self.type = type
              self.onChange = onChange
              super.init()
            }

            override func observeValue(
              forKeyPath keyPath: String?,
              of object: Any?,
              change: [NSKeyValueChangeKey: Any]?,
              context: UnsafeMutableRawPointer?
            ) {
              self.onChange(
                (object as! UserDefaults).getSendable(forKey: self.key, as: self.type)
              )
            }
          }

          let object = Observer(key: key, type: type) {
            continuation.yield($0)
          }

          userDefaults.value.addObserver(
            object,
            forKeyPath: key,
            options: [.initial, .new],
            context: nil
          )
          continuation.onTermination = { _ in
            userDefaults.value.removeObserver(object, forKeyPath: key)
          }
        #else
          print("AsyncStream of UserDefaults values is currently not supported on Linux")
          continuation.finish()
        #endif
      }
    }
  }

  /// Creates an `UserDefaults.Dependency` corresponding to `UserDefaults.standard`.
  public static var standard: UserDefaults.Dependency { .init() }

  /// Creates an `UserDefaults.Dependency` corresponding to `UserDefaults?(suitename: String?)`.
  public init?(suitename: String?) {
    guard let userDefaults = UserDefaults(suiteName: suitename) else { return nil }
    self = .init(userDefaults)
  }

  // TODO: NSUbiquitousKeyValueStore variant?
}

extension UserDefaults {
  fileprivate func contains(key: String) -> Bool {
    self.object(forKey: key) != nil
  }

  fileprivate func getSendable(forKey key: String, as type: Any.Type) -> (any Sendable)? {
    switch type {
    case let type where type == Bool.self, let type where type == Bool?.self:
      guard self.contains(key: key) else { return nil }
      return self.bool(forKey: key)
    case let type where type == Data.self, let type where type == Data?.self:
      return self.data(forKey: key)
    case let type where type == Date.self, let type where type == Date?.self:
      return self.object(forKey: key) as? Date
    case let type where type == Double.self, let type where type == Double?.self:
      guard self.contains(key: key) else { return nil }
      return self.double(forKey: key)
    case let type where type == Int.self, let type where type == Int?.self:
      guard self.contains(key: key) else { return nil }
      return self.integer(forKey: key)
    case let type where type == String.self, let type where type == String?.self:
      return self.string(forKey: key)
    case let type where type == URL.self, let type where type == URL?.self:
      return self.url(forKey: key)
    default:
      return nil
    }
  }

  fileprivate func setSendable(_ value: (any Sendable)?, forKey key: String) {
    guard let value = value else {
      self.removeObject(forKey: key)
      return
    }
    switch value {
    case let value as Bool:
      self.set(value, forKey: key)
    case let value as Data:
      self.set(value, forKey: key)
    case let value as Date:
      self.set(value, forKey: key)
    case let value as Double:
      self.set(value, forKey: key)
    case let value as Int:
      self.set(value, forKey: key)
    case let value as String:
      self.set(value, forKey: key)
    case let value as URL:
      self.set(value, forKey: key)
    default:
      return
    }
  }
}
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  @available(iOS 5.0, tvOS 9.0, macOS 10.7, watchOS 9.0, *)
  extension NSUbiquitousKeyValueStore {
    fileprivate func contains(key: String) -> Bool {
      self.object(forKey: key) != nil
    }

    fileprivate func getSendable(forKey key: String, as type: Any.Type) -> (any Sendable)? {
      switch type {
      case let type where type == Bool.self, let type where type == Bool?.self:
        guard self.contains(key: key) else { return nil }
        return self.bool(forKey: key)
      case let type where type == Data.self, let type where type == Data?.self:
        return self.data(forKey: key)
      case let type where type == Date.self, let type where type == Date?.self:
        return self.object(forKey: key) as? Date
      case let type where type == Double.self, let type where type == Double?.self:
        guard self.contains(key: key) else { return nil }
        return self.double(forKey: key)
      case let type where type == Int.self, let type where type == Int?.self:
        guard self.contains(key: key) else { return nil }
        return Int(self.longLong(forKey: key))
      case let type where type == String.self, let type where type == String?.self:
        return self.string(forKey: key)
      case let type where type == URL.self, let type where type == URL?.self:
        // TODO: Improve to handle file urls
        guard let string = self.string(forKey: key) else { return nil }
        return URL(string: string)
      default:
        return nil
      }
    }

    fileprivate func setSendable(_ value: (any Sendable)?, forKey key: String) {
      guard let value = value else {
        self.removeObject(forKey: key)
        return
      }
      switch value {
      case let value as Bool:
        self.set(value, forKey: key)
      case let value as Data:
        self.set(value, forKey: key)
      case let value as Date:
        self.set(value, forKey: key)
      case let value as Double:
        self.set(value, forKey: key)
      case let value as Int:
        self.set(value, forKey: key)
      case let value as String:
        self.set(value, forKey: key)
      case let value as URL:
        // TODO: Improve to handle file urls
        self.set(value.absoluteString, forKey: key)
      default:
        return
      }
    }
  }
#endif
extension UserDefaults.Dependency: TestDependencyKey {
  public static let testValue: Self = {
    XCTFail(#"Unimplemented: @Dependency(\.userDefaults)"#)
    return ephemeral()
  }()

  public static var previewValue: Self { ephemeral() }

  /// An ephemeral ``UserDefaults.Dependency`` that reads from and writes to memory only.
  ///
  /// It behaves similarly to a `UserDefaults`-backed ``UserDefaults.Dependency``, but without the
  /// persistance layer. This makes this value convienent for testing or SwiftUI previews.
  ///
  /// Please note that the behavior can be sligtly different when storing/reading `URL`s, as
  /// `UserDefaults` normalizes `URL` values before storing them (you can check the documentation of
  /// `UserDefaults.set(:URL?:String)` for more information).
  public static func ephemeral() -> UserDefaults.Dependency {
    let storage = LockIsolated([String: any Sendable]())
    let continuations = LockIsolated([String: [UUID: AsyncStream<(any Sendable)?>.Continuation]]())

    return UserDefaults.Dependency { key, _ in
      storage.value[key]
    } set: { value, key in
      let valueDidChange = LockIsolated(false)
      storage.withValue {
        valueDidChange.setValue(!_isEqual($0[key], value))
        $0[key] = value
      }
      if valueDidChange.value {
        for continuation in continuations.value[key]?.values ?? [:].values {
          continuation.yield(value)
        }
      }
    } values: { key, _ in
      let id = UUID()
      let (stream, continuation) = AsyncStream.makeStream(
        of: (any Sendable)?.self,
        bufferingPolicy: .bufferingNewest(1)
      )
      continuations.withValue {
        $0[key, default: [:]][id] = continuation
      }
      continuation.yield(storage.value[key])
      return stream
    }
  }
}

private func _isEqual(_ lhs: (any Sendable)?, _ rhs: (any Sendable)?) -> Bool {
  switch (lhs, rhs) {
  case let (.some(lhs), .some(rhs)):
    return (lhs as! any Equatable).isEqual(other: rhs)
  case (.none, .none):
    return type(of: lhs) == type(of: rhs)
  case (.some, .none), (.none, .some): return false
  }
}

extension Equatable {
  fileprivate func isEqual(other: Any) -> Bool {
    self == other as? Self
  }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  extension UserDefaults.Dependency {
    /// An iCloud-based container of key-value pairs you use to share data among
    /// instances of your app running on a user's connected devices.
    @available(iOS 5.0, tvOS 9.0, macOS 10.7, watchOS 9.0, *)
    public static var ubiquitous: UserDefaults.Dependency {
      let store = NSUbiquitousKeyValueStore.default
      let userDefaults = UncheckedSendable(store)
      let subject = AsyncSharedSubject<(String, any Sendable)>()

      return UserDefaults.Dependency { key, type in
        userDefaults.value.getSendable(forKey: key, as: type)
      } set: {
        userDefaults.value.setSendable($0, forKey: $1)
        // NSUbiquitousKeyValueStore doesn't support KVO, so we call directly
        // the continuation for local changes.
        subject.yield(($1, $0))
        userDefaults.value.synchronize()
      } values: { key, type in
        AsyncStream((any Sendable)?.self) { continuation in
          final class Observer: NSObject, Sendable {
            let key: String
            let type: Any.Type
            let onChange: @Sendable ((any Sendable)?) -> Void
            init(
              key: String,
              type: Any.Type,
              onChange: @escaping @Sendable ((any Sendable)?) -> Void
            ) {
              self.key = key
              self.type = type
              self.onChange = onChange
              super.init()
              NotificationCenter.default.addObserver(
                self, selector: #selector(onNotification),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: NSUbiquitousKeyValueStore.default
              )
            }

            @objc func onNotification(_ notification: Notification) {
              guard
                let store = notification.object as? NSUbiquitousKeyValueStore,
                let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey]
                  as? [String],
                keys.contains(key)
              else { return }
              self.onChange(store.getSendable(forKey: self.key, as: self.type))
            }
          }

          let object = Observer(key: key, type: type) {
            subject.yield((key, $0))
          }

          let task = Task {
            for await tuple in subject.stream(bufferingPolicy: .bufferingNewest(0)) {
              if tuple.0 == key {
                continuation.yield(tuple.1)
              }
            }
          }

          continuation.onTermination = { [object] _ in
            task.cancel()
            let _ = object
          }
        }
      }
    }
  }
#endif

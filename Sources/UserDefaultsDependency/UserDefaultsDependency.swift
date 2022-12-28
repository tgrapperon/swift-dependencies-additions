@_exported import Dependencies
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
    public func values<T>(forKey key: String) -> AsyncMapSequence<AsyncStream<(any Sendable)?>, T?> {
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

private extension UserDefaults {
  func contains(key: String) -> Bool {
    self.object(forKey: key) != nil
  }

  func getSendable(forKey key: String, as type: Any.Type) -> (any Sendable)? {
    switch type {
    case let type where type == Bool.self, let type where type == Bool?.self:
      guard self.contains(key: key) else { return nil }
      return self.bool(forKey: key)
    case let type where type == Int.self, let type where type == Int?.self:
      guard self.contains(key: key) else { return nil }
      return self.integer(forKey: key)
    case let type where type == Double.self, let type where type == Double?.self:
      guard self.contains(key: key) else { return nil }
      return self.double(forKey: key)
    case let type where type == Data.self, let type where type == Data?.self:
      return self.data(forKey: key)
    case let type where type == String.self, let type where type == String?.self:
      return self.string(forKey: key)
    case let type where type == URL.self, let type where type == URL?.self:
      return self.url(forKey: key)
    default:
      return nil
    }
  }

  func setSendable(_ value: (any Sendable)?, forKey key: String) {
    guard let value = value else {
      self.removeObject(forKey: key)
      return
    }
    switch value {
    case let value as Bool:
      self.set(value, forKey: key)
    case let value as Int:
      self.set(value, forKey: key)
    case let value as Double:
      self.set(value, forKey: key)
    case let value as Data:
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
      storage.withValue {
        $0[key] = value
      }
      for continuation in continuations.value[key]?.values ?? [:].values {
        continuation.yield(value)
      }
    } values: { key, _ in
      let id = UUID()
      let stream = AsyncStream((any Sendable)?.self) { streamContinuation in
        continuations.withValue {
          $0[key, default: [:]][id] = streamContinuation
        }
      }
      defer { continuations.value[key]?[id]?.yield(storage.value[key]) }
      return stream
    }
  }
}

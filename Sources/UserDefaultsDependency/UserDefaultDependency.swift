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
    func object<T: Sendable>(forKey key: String) -> T? {
      self._get(key, T.self) as? T
    }

    /// Sets the value of the specified default key.
    func set<T: Sendable>(_ value: T?, forKey key: String) {
      self._set(value, key)
    }

    /// An `AsyncStream` of values for a given `key` as they change. The stream produces `nil` if
    /// the value is removed or if no value exists for the given key.
    /// - Parameter key: The key that references this user preference.
    /// - Returns: An `AsyncSequence` of `T?` values, including the initial value.
    func values<T>(forKey key: String) -> AsyncMapSequence<AsyncStream<(any Sendable)?>, T?> {
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

extension UserDefaults.Dependency {
  /// Returns the Boolean value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Boolean value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func bool(forKey key: String) -> Bool? {
    self._get(key, Bool.self) as? Bool
  }

  /// Sets the value of the specified default key to the specified Boolean value.
  /// - Parameters:
  ///   - value: The Boolean value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Bool?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Data value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Data value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func data(forKey key: String) -> Data? {
    self._get(key, Date.self) as? Data
  }

  /// Sets the value of the specified default key to the specified Data value.
  /// - Parameters:
  ///   - value: The Data value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Data?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Double value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Double value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func double(forKey key: String) -> Double? {
    self._get(key, String.self) as? Double
  }

  /// Sets the value of the specified default key to the specified Double value.
  /// - Parameters:
  ///   - value: The Double value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Double?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Int value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Int value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func integer(forKey key: String) -> Int? {
    self._get(key, Int.self) as? Int
  }

  /// Sets the value of the specified default key to the specified Int value.
  /// - Parameters:
  ///   - value: The Int value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Int?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the String value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The String value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func string(forKey key: String) -> String? {
    self._get(key, String.self) as? String
  }

  /// Sets the value of the specified default key to the specified String value.
  /// - Parameters:
  ///   - value: The String value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: String?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the URL value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The URL value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func url(forKey key: String) -> URL? {
    self._get(key, URL.self) as? URL
  }

  /// Sets the value of the specified default key to the specified URL value.
  /// - Parameters:
  ///   - value: The URL value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: URL?, forKey key: String) {
    self._set(value, key)
  }

  /// Removes the specified for the specified key. You can alternatively set a `nil` value using
  /// any typed ``set(_:forKey:)`` overload.
  public func removeValue(forKey key: String) {
    self._set(nil, key)
  }
}

extension UserDefaults.Dependency {
  /// Returns a RawRepresentable value `R` associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The RawRepresentable value `R` associated with the specified key, or `nil` if there
  /// is no value associated to `key`, or if `R` cannot be built from the associated value.
  public func rawRepresentable<R: RawRepresentable>(forKey key: String) -> R?
    where R.RawValue == String
  {
    self.string(forKey: key).flatMap(R.init(rawValue:))
  }

  /// Sets the value of the specified default key to the specified RawRepresentable `R` value.
  /// - Parameters:
  ///   - value: The RawRepresentable `R` value to store in the user's defaults store. If the value
  ///   is `nil`, the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set<R: RawRepresentable>(_ value: R?, forKey key: String) where R.RawValue == String {
    self._set(value?.rawValue, key)
  }

  /// Returns a RawRepresentable value `R` associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The RawRepresentable value `R` associated with the specified key, or `nil` if there
  /// is no value associated to `key`, or if `R` cannot be built from the associated value.
  public func rawRepresentable<R: RawRepresentable>(forKey key: String) -> R?
    where R.RawValue == Int
  {
    self.integer(forKey: key).flatMap(R.init(rawValue:))
  }

  /// Sets the value of the specified default key to the specified RawRepresentable `R` value.
  /// - Parameters:
  ///   - value: The RawRepresentable `R` value to store in the user's defaults store. If the value
  ///   is `nil`, the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set<R: RawRepresentable>(_ value: R?, forKey key: String) where R.RawValue == Int {
    self._set(value?.rawValue, key)
  }
}

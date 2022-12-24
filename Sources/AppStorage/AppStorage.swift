import Dependencies
import Foundation
import XCTestDynamicOverlay

// `AppStorage` is now nested in `Dependency`, from which it inherits the `Value` generics. This
// allows to use the non-ambiguous `@Depedency.AppStorage("somKey") = 44`, or to simply define a
// typealias like below to use `AppStorage("someKey") = 44` directly. This typealias can be defined
// in types where we would want this `AppStorage` to take precedence over SwiftUI's one, like in
// some `ReducerProtocol` or `ObservableObject` extension for example.

// Note: I finally made the `AppStorage` wrapper a class in order to be able to be captured and
// mutated in concurrent contexts. All fields are constants and thread safety is deferred to the
// corresponding `userDefaults` which are themselve thread safe by construction.

/// A property wrapper type that reflects a value from `UserDefaults`.
/// This property wrapper can be used in `ObservableObject` instances, or anywhere the
/// ``DependencyValues/userDefaults`` dependency is defined.
///
/// - Note: This version of `AppStorage` should inter-operate seamlessly with SwiftUI's own version
/// of this property wrapper, provided you're using the same keys to save the same types of values.
public typealias AppStorage<Value> = Dependency<Value>.AppStorage

public extension Dependency {
  // NB: Repeted doc in order to be displayed in Xcode's right side bar.
  /// A property wrapper type that reflects a value from `UserDefaults`.
  /// This property wrapper can be used in `ObservableObject` instances, or anywhere the
  /// ``DependencyValues/userDefaults`` dependency is defined.
  ///
  /// - Note: This version of `AppStorage` should inter-operate seamlessly with SwiftUI's own
  /// version of this property wrapper, provided you're using the same keys to save the same types
  /// of values.
  @propertyWrapper
  @dynamicMemberLookup
  final class AppStorage: Sendable where Value: Sendable {
    let key: String
    let defaultValue: Value
    let explicitUserDefaults: UserDefaults.Dependency?

    let getValue: @Sendable (UserDefaults.Dependency) -> Value
    let setValue: @Sendable (UserDefaults.Dependency, Value) -> Void

    private var userDefaults: UserDefaults.Dependency {
      @Dependency<UserDefaults.Dependency>(\.userDefaults) var currentUserDefaults
      return self.explicitUserDefaults ?? currentUserDefaults
    }

    public var wrappedValue: Value {
      get {
        self.getValue(self.userDefaults)
      }
      set {
        self.setValue(self.userDefaults, newValue)
      }
    }

    public var projectedValue: AppStorage {
      self
    }

    // Convenience getter that mirrors `set` for cross concurrency context access
    public func get() -> Value {
      self.wrappedValue
    }

    // Convenience setter for cross concurrency context access
    public func set(_ value: Value) {
      self.wrappedValue = value
    }

    /// Resets the current value to its defaults.
    public func reset() {
      // TODO: Passing `Value?.none` is technically incorrect for raw representable, but the value's
      // type is not used to delete a key. This should be fixed at some point though.
      self.userDefaults.set(Value?.none, forKey: self.key)
    }

    /// An `AsyncStream` of the values for this key as they change.
    ///
    /// It always immediately emits the initial value as the first element when you enumerate it.
    public func values() -> AsyncStream<Value> {
      self.userDefaults
        .values(forKey: self.key)
        .map { [defaultValue = self.defaultValue] in $0 ?? defaultValue }
        .eraseToStream()
    }

    init(
      key: String,
      defaultValue: Value,
      userDefaults: UserDefaults.Dependency? = nil,
      getValue: @escaping @Sendable (UserDefaults.Dependency) -> Value,
      setValue: @escaping @Sendable (UserDefaults.Dependency, Value) -> Void
    ) {
      self.explicitUserDefaults = userDefaults
      self.getValue = getValue
      self.setValue = setValue
      self.key = key
      self.defaultValue = defaultValue
    }

    // Internal initializer with default value
    convenience init(wrappedValue: Value, key: String, store: UserDefaults.Dependency? = nil) {
      self.init(
        key: key,
        defaultValue: wrappedValue,
        userDefaults: store
      ) {
        $0.object(forKey: key) ?? wrappedValue
      } setValue: {
        $0.set($1, forKey: key)
      }
    }

    // Internal initializer without default value
    convenience init<Wrapped>(key: String, store: UserDefaults.Dependency? = nil)
      where Value == Wrapped?
    {
      self.init(
        key: key,
        defaultValue: nil,
        userDefaults: store
      ) {
        $0.object(forKey: key)
      } setValue: {
        $0.set($1, forKey: key)
      }
    }

    @_disfavoredOverload
    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T { self.wrappedValue[keyPath: keyPath] }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
      get { self.wrappedValue[keyPath: keyPath] }
      set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
  }
}

public extension DependencyValues {
  /// A dependency that exposes an ``UserDefaults.Dependency`` value that you can use to read and
  /// write to `UserDefaults`.
  var userDefaults: UserDefaults.Dependency {
    get { self[UserDefaults.Dependency.self] }
    set { self[UserDefaults.Dependency.self] = newValue }
  }
}

/// A type that abstract `UserDefaults` storage. You can use this type as it, or build your
/// own abstraction on top of it.
public extension UserDefaults {
  struct Dependency: Sendable {
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
    case let type where type == Bool.self:
      guard self.contains(key: key) else { return nil }
      return self.bool(forKey: key)
    case let type where type == Int.self:
      guard self.contains(key: key) else { return nil }
      return self.integer(forKey: key)
    case let type where type == Double.self:
      guard self.contains(key: key) else { return nil }
      return self.double(forKey: key)
    case let type where type == Data.self:
      return self.data(forKey: key)
    case let type where type == String.self:
      return self.string(forKey: key)
    case let type where type == URL.self:
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
    let continuation = LockIsolated<AsyncStream<(String, (any Sendable)?)>.Continuation?>(nil)

    return UserDefaults.Dependency { key, _ in
      storage.value[key]
    } set: { value, key in
      storage.withValue {
        $0[key] = value
      }
      continuation.value?.yield((key, value))
    } values: { key, _ in
      let stream = AsyncStream((String, (any Sendable)?).self) { streamContinuation in
        continuation.withValue { $0 = streamContinuation }
      }
      defer { continuation.value?.yield((key, storage.value[key])) }
      return
        stream
          .filter { $0.0 == key }
          .map(\.1)
          .eraseToStream()
    }
  }
}

// Specializations
public extension Dependency.AppStorage {
  /// Creates a property that can read and write to a boolean user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a boolean value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Bool
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to an integer user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Int
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to a double user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a double value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Double
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to a string user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == String
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to a url user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a url value is not specified for
  ///     the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == URL
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to a user default as data.
  ///
  /// Avoid storing large data blobs in user defaults, such as image data,
  /// as it can negatively affect performance of your app. On tvOS, a
  /// `NSUserDefaultsSizeLimitExceededNotification` notification is posted
  /// if the total user default size reaches 512kB.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a data value is not specified for
  ///    the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Data
  {
    self.init(wrappedValue: wrappedValue, key: key, store: store)
  }

  /// Creates a property that can read and write to an integer user default,
  /// transforming that to `RawRepresentable` data type.
  ///
  /// A common usage is with enumerations:
  ///
  ///    enum MyEnum: Int {
  ///        case a
  ///        case b
  ///        case c
  ///    }
  ///    struct MyView: View {
  ///        @AppStorage("MyEnumValue") private var value = MyEnum.a
  ///        var body: some View { ... }
  ///    }
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value
  ///     is not specified for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value: RawRepresentable, Value.RawValue == Int
  {
    self.init(
      key: key,
      defaultValue: wrappedValue,
      userDefaults: store
    ) {
      ($0.object(forKey: key) as Value.RawValue?).flatMap(Value.init(rawValue:)) ?? wrappedValue
    } setValue: {
      $0.set($1.rawValue, forKey: key)
    }
  }

  /// Creates a property that can read and write to a string user default,
  /// transforming that to `RawRepresentable` data type.
  ///
  /// A common usage is with enumerations:
  ///
  ///    enum MyEnum: String {
  ///        case a
  ///        case b
  ///        case c
  ///    }
  ///    struct MyView: View {
  ///        @AppStorage("MyEnumValue") private var value = MyEnum.a
  ///        var body: some View { ... }
  ///    }
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value
  ///     is not specified for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(wrappedValue: Value, _ key: String, store: UserDefaults.Dependency? = nil)
    where Value: RawRepresentable, Value.RawValue == String
  {
    self.init(
      key: key,
      defaultValue: wrappedValue,
      userDefaults: store
    ) {
      ($0.object(forKey: key) as Value.RawValue?).flatMap(Value.init(rawValue:)) ?? wrappedValue
    } setValue: {
      $0.set($1.rawValue, forKey: key)
    }
  }
}

public extension Dependency.AppStorage where Value: ExpressibleByNilLiteral {
  /// Creates a property that can read and write an Optional boolean user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Bool?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can read and write an Optional integer user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Int?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can read and write an Optional double user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Double?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can read and write an Optional string user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == String?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can read and write an Optional URL user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == URL?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can read and write an Optional data user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == Data?
  {
    self.init(key: key, store: store)
  }

  /// Creates a property that can save and restore an Optional integer,
  /// transforming it to an Optional `RawRepresentable` data type.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// A common usage is with enumerations:
  ///
  ///     enum MyEnum: Int {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @AppStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init<R>(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == Int
  {
    self.init(
      key: key,
      defaultValue: nil,
      userDefaults: store
    ) {
      ($0.object(forKey: key) as R.RawValue?).flatMap(R.init(rawValue:))
    } setValue: {
      $0.set($1?.rawValue, forKey: key)
    }
  }

  /// Creates a property that can save and restore an Optional string,
  /// transforming it to an Optional `RawRepresentable` data type.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// A common usage is with enumerations:
  ///
  ///     enum MyEnum: String {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @AppStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the dependencies.
  convenience init<R>(_ key: String, store: UserDefaults.Dependency? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == String
  {
    self.init(
      key: key,
      defaultValue: nil,
      userDefaults: store
    ) {
      ($0.object(forKey: key) as R.RawValue?).flatMap(R.init(rawValue:))
    } setValue: {
      $0.set($1?.rawValue, forKey: key)
    }
  }
}

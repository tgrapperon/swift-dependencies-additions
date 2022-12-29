import Dependencies
@_spi(Internals) @_exported import UserDefaultsDependency
import Foundation
import XCTestDynamicOverlay


// Note: `AppStorage` wrapper is class in order to be able to be captured and mutated in concurrent
// contexts. All fields are constants and thread safety is deferred to the corresponding
// `userDefaults`, which are themselve thread safe by construction.

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
    let initialValues: DependencyValues

    let key: String
    let defaultValue: Value
    let explicitUserDefaults: UserDefaults.Dependency?

    let getValue: @Sendable (UserDefaults.Dependency) -> Value
    let setValue: @Sendable (UserDefaults.Dependency, Value) -> Void

    private var userDefaults: UserDefaults.Dependency {
      #warning("Fix this if possible")
//      let currentUserDefaults = self.initialValues.merging(DependencyValues._current)[keyPath:\.userDefaults]
      let currentUserDefaults = self.initialValues[keyPath:\.userDefaults]
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
      self.initialValues = DependencyValues._current
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


import Dependencies
import Foundation
@_spi(Internals) @_exported import UserDefaultsDependency
import XCTestDynamicOverlay

extension Dependency {
  @propertyWrapper
  @dynamicMemberLookup
  public struct AppStorage: Sendable where Value: Sendable {
    @Dependencies.Dependency(\.userDefaults) var currentUserDefaults

    let key: String
    let defaultValue: Value
    let explicitUserDefaults: UserDefaults.Dependency?

    let getValue: @Sendable (UserDefaults.Dependency) -> Value
    let setValue: @Sendable (UserDefaults.Dependency, Value) -> Void

    private var userDefaults: UserDefaults.Dependency {
      self.explicitUserDefaults ?? self.currentUserDefaults
    }

    public var wrappedValue: Value {
      get { self.getValue(self.userDefaults) }
      nonmutating set { self.setValue(self.userDefaults, newValue) }
    }

    public var projectedValue: Values {
      Values {
        // Note: Passing `Value?.none` is technically incorrect for raw representable, but the
        // value's type itself is not used to delete a key. This should be fixed at some point
        // though.
        self.userDefaults.set(Value?.none, forKey: self.key)
      } stream: {
        self.userDefaults
          .values(forKey: self.key)
          .map { $0 ?? defaultValue }
          .eraseToStream()
      }
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
    init(wrappedValue: Value, key: String, store: UserDefaults.Dependency? = nil) {
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
    init<Wrapped>(key: String, store: UserDefaults.Dependency? = nil)
    where Value == Wrapped? {
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
    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
      self.wrappedValue[keyPath: keyPath]
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
      get { self.wrappedValue[keyPath: keyPath] }
      set { self.wrappedValue[keyPath: keyPath] = newValue }
    }
  }
}

extension Dependency.AppStorage {
  /// An `AsyncSequence` of the values for this key as they change.
  ///
  /// It always immediately emits the current value as the first element when you enumerate it.
  public struct Values: Sendable, AsyncSequence {
    public typealias Element = Value
    let _reset: @Sendable () -> Void
    let _stream: @Sendable () -> AsyncStream<Value>
    init(
      reset: @escaping @Sendable () -> Void, stream: @escaping @Sendable () -> AsyncStream<Value>
    ) {
      self._reset = reset
      self._stream = stream
    }

    /// Resets the current value to its defaults.
    public func reset() { self._reset() }

    public func makeAsyncIterator() -> AsyncStream<Value>.AsyncIterator {
      self._stream().makeAsyncIterator()
    }
  }
}

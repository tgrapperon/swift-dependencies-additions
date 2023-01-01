import Foundation
/// A property wrapper that delegates the storage of a property to an internal closure.
///
/// This property wrapper is useful when defining dependencies as abstractions of existing types
/// exposing properties, as the live implementation can lazily delegate calls to some abstracted
/// type's instance.
@propertyWrapper
public struct LazyProxy<Value: Sendable>: Sendable {
  private let lock = NSRecursiveLock()
  private var getValue: @Sendable () -> Value
  private let setValue: @Sendable (Value) -> Void
  public init(_ getSet: (@Sendable () -> Value, @Sendable (Value) -> ())) {
    self.getValue = getSet.0
    self.setValue = getSet.1
  }
  public var wrappedValue: Value {
    get {
      lock.lock()
      defer { lock.unlock() }
      return self.getValue()
    }
    nonmutating set {
      self.setValue(newValue)
    }
  }
  
  public var projectedValue: Value {
    get { wrappedValue }
    set {
      lock.lock()
      defer { lock.unlock() }
      // Should we display messages in the econsole?
//      self.setValue(newValue) // Should we?
      self.getValue = { @Sendable in newValue }
    }
  }
}

/// See ``LazyProxy``.
public typealias LP = LazyProxy

/// A property wrapper that delegates the storage of a property to an internal closure.
///
/// This property wrapper is useful when defining dependencies as abstractions of existing types
/// exposing properties, as the live implementation can lazily delegate calls to some abstracted
/// type's instance.
///
/// This is a read-only version of ``LazyProxy``. You can write to it through the projected value
/// to create mocks or for testing for example.
@propertyWrapper
public struct ReadOnlyLazyProxy<Value> {
  private let lock = NSRecursiveLock()
  private var value: () -> Value
  public init(_ value: @escaping () -> Value) {
    self.value = value
  }
  public var wrappedValue: Value {
    get {
      lock.lock()
      defer { lock.unlock() }
      return value()
    }
  }
  
  public var projectedValue: Value {
    get { wrappedValue }
    set {
      lock.lock()
      defer { lock.unlock() }
      self.value = { newValue }
    }
  }
}

extension ReadOnlyLazyProxy: @unchecked Sendable where Value: Sendable {}

/// See ``ReadOnlyLazyProxy``.
public typealias ROLP = ReadOnlyLazyProxy

/// A property wrapper that delegates the storage of a property to a `@MainActor` internal closure.
///
/// This property wrapper is useful when defining dependencies as abstractions of existing
/// `@MainActor`-isolated types that are exposing properties, as the live implementation can lazily
/// delegate calls to some instance of the abstracted type's. In such cases, it also facilitate the
/// creation of these abtracted dependencies' values in non-isolated context, with is a requirement
/// of `DependencyKey`.
@propertyWrapper
public struct MainActorLazyProxy<Value> {
  private var getValue: @MainActor () -> Value
  private let setValue: @MainActor (Value) -> Void
  public init(_ getSet: (@MainActor () -> Value, @MainActor (Value) -> Void)) {
    self.getValue = getSet.0
    self.setValue = getSet.1
  }
  @MainActor
  public var wrappedValue: Value {
    get {
      self.getValue()
    }
    nonmutating set {
      self.setValue(newValue)
    }
  }
  
  @MainActor
  public var projectedValue: Value {
    get {
      getValue()
    }
    set {
      // TODO: Should we display messages in the console?
      // TODO: This is only for testing and preview. We should check. Same for LP
      self.getValue = { newValue }
    }
  }
}
/// See ``MainActorLazyProxy``.
public typealias MALP = MainActorLazyProxy

/// A property wrapper that delegates the storage of a property to a `@MainActor` internal closure.
///
/// This property wrapper is useful when defining dependencies as abstractions of existing
/// `@MainActor`-isolated types that are exposing properties, as the live implementation can lazily
/// delegate calls to some instance of the abstracted type's. In such cases, it also facilitate the
/// creation of these abtracted dependencies' values in non-isolated context, with is a requirement
/// of `DependencyKey`.
///
/// This is a read-only version of ``MainActorLazyProxy``. You can write to it through the projected value to create mocks or for testing for example.
@propertyWrapper
public struct ReadOnlyMainActorLazyProxy<Value> {
  private var value: @MainActor () -> Value
  public init(_ value: @escaping @MainActor () -> Value) {
    self.value = value
  }
  @MainActor
  public var wrappedValue: Value {
    get { value() }
  }
  
  @MainActor
  public var projectedValue: Value {
    get {
      value()
    }
    set {
      self.value = { newValue }
    }
  }
}

/// See ``MainActorReadOnlyLazyProxy``.
public typealias ROMALP = ReadOnlyMainActorLazyProxy

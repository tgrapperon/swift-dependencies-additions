import Foundation
/// A property wrapper that delegates the storage of a property to an internal closure.
///
/// This property wrapper is useful when defining dependencies as abstractions of existing types
/// exposing properties, as the live implementation can lazily delegate calls to some abstracted
/// type's instance.
@propertyWrapper
public struct LazyProxy<Value> {
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
    set {
      lock.lock()
      defer { lock.unlock() }
      self.value = { newValue }
    }
  }
}

extension LazyProxy: @unchecked Sendable where Value: Sendable {}

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
  private var value: @MainActor () -> Value
  public init(_ value: @escaping @MainActor () -> Value) {
    self.value = value
  }
  @MainActor
  public var wrappedValue: Value {
    get {
      value()
    }
    set {
      self.value = { newValue }
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
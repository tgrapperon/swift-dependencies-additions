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


struct Test {
  
  var string: @MainActor () -> String
  
  init(string: @MainActor @escaping () -> String) {
    self.string = string
  }

}
import UIKit
let test = Test {
  UIDevice.current.name
}

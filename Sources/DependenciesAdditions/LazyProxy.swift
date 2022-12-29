import Foundation
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

@propertyWrapper
public struct MainActorLazyProxy<Value> {
  private let lock = NSRecursiveLock()
  private var value: @MainActor () -> Value
  public init(_ value: @escaping @MainActor () -> Value) {
    self.value = value
  }
  @MainActor
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

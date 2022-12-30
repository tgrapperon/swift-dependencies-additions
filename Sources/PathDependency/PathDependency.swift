import Dependencies
import Foundation

extension Path: DependencyKey {
  public static var liveValue: Path { .empty }
  public static var testValue: Path { .empty }
}

extension DependencyValues {
  /// A generalized `Path` value
  public var path: Path {
    get { self[Path.self] }
    set { self[Path.self] = newValue }
  }
}

public struct Path: Hashable, @unchecked Sendable {
  let lock = NSRecursiveLock()
  private var _components = [AnyHashable]()

  public static var empty: Path { .init() }

  public var components: [AnyHashable] {
    // components are guaranteed to be `Sendable` by the exposed API.
    lock.lock()
    defer { lock.unlock() }
    return _components
  }

  public mutating func push<Component: Hashable & Sendable>(_ component: Component) {
    lock.lock()
    defer { lock.unlock() }
    _components.append(component)
  }

  public func pushing<Component: Hashable & Sendable>(_ component: Component) -> Self {
    var path = self
    path.push(component)
    return path
  }

  public mutating func popLast() {
    lock.lock()
    defer { lock.unlock() }
    if !_components.isEmpty {
      _components.removeLast()
    }
  }

  public func poppingLast() -> Self {
    var path = self
    path.popLast()
    return path
  }
}

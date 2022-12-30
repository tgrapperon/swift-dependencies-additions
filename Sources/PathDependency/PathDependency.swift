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

  /// Creates an empty path.
  public static var empty: Path { .init() }

  /// The components of the path, under the form of an array of `AnyHashable`.
  public var components: [AnyHashable] {
    // components are guaranteed to be `Sendable` by the exposed API.
    lock.lock()
    defer { lock.unlock() }
    return _components
  }

  /// Appends a new component to a path.
  public mutating func push<Component: Hashable & Sendable>(_ component: Component) {
    lock.lock()
    defer { lock.unlock() }
    _components.append(component)
  }

  /// Returns a new ``Path`` with provided component being appended to it.
  public func pushing<Component: Hashable & Sendable>(_ component: Component) -> Self {
    var path = self
    path.push(component)
    return path
  }

  /// Removes the last component if any. Does nothing if the path is empty.
  public mutating func popLast() {
    lock.lock()
    defer { lock.unlock() }
    if !_components.isEmpty {
      _components.removeLast()
    }
  }

  /// Returns a new ``Path`` where the last component has been removed.
  public func poppingLast() -> Self {
    if _components.isEmpty { return self }
    var path = self
    path.popLast()
    return path
  }
}

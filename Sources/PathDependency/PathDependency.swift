import Dependencies
import Foundation

extension Path: DependencyKey {
  /// An empty ``Path``
  public static var liveValue: Path { .empty }
  /// An unimplemented ``Path``
  public static var testValue: Path { .unimplemented }
}

extension DependencyValues {
  /// A generalized and barebone `Path` value, onto which you can push and pop arbitrary `Hashable`
  /// values.
  ///
  /// You can use this type as a kind of structural identifier to help you contextualize and reuse
  /// models for example.
  public var path: Path {
    get { self[Path.self] }
    set { self[Path.self] = newValue }
  }
}

extension Path {
  /// Creates an empty path.
  public static var empty: Path { .init() }

  /// An `unimplemented` that fails tests.
  public static var unimplemented: Path {
    .init(XCTestDynamicOverlay.unimplemented(#"@Dependency(\.path)"#))
  }
}

/// A generalized and barebone `Path` value, onto which you can push and pop arbitrary `Hashable`
/// values.
public struct Path: Hashable, @unchecked Sendable {
  private var _components = [AnyHashable]()

  init(_ components: @autoclosure () -> [AnyHashable] = []) {
    self._components = components()
  }

  /// The components of the path, under the form of an array of `AnyHashable`.
  public var components: [AnyHashable] {
    // Components are guaranteed to be `Sendable` by the exposed API.
    _components
  }

  /// Appends a new component to a path.
  public mutating func append<Component: Hashable & Sendable>(_ component: Component) {
    _components.append(component)
  }

  /// Returns a new ``Path`` with provided component being appended to it.
  public func appending<Component: Hashable & Sendable>(_ component: Component) -> Self {
    var path = self
    path.append(component)
    return path
  }

  /// Removes the last component if any. Does nothing if the path is empty.
  public mutating func popLast() {
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

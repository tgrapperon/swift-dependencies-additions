import Dependencies
import Foundation

extension Path: DependencyKey {
  public static var liveValue: Path { .init() }
  public static var testValue: Path { .init() }
}

extension DependencyValues {
  public var path: Path {
    get { self[Path.self] }
    set { self[Path.self] = newValue }
  }
}

public struct Path: Hashable, Sendable {
  private let _components = LockIsolated([AnyHashable]())

  public static var empty: Path { .init() }

  public var components: [AnyHashable] {
    // components are guaranteed to be `Sendable` by the exposed API.
    _components.withValue { UncheckedSendable($0) }.wrappedValue
  }

  public func push<Component: Hashable & Sendable>(_ component: Component) {
    self._components.withValue {
      $0.append(component)
    }
  }

  public func pushing<Component: Hashable & Sendable>(_ component: Component) -> Self {
    var path = self
    path.push(component)
    return path
  }

  public func popLast() {
    self._components.withValue {
      if !$0.isEmpty {
        $0.removeLast()
      }
    }
  }

  public func poppingLast() -> Self {
    var path = self
    path.popLast()
    return path
  }
}

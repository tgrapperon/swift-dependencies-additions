import Dependencies

extension DependencyValues {
  public var debug: DebugDependency {
    get { self[DebugDependency.self] }
    set { self[DebugDependency.self] = newValue }
  }
}

extension DebugDependency: DependencyKey {
  public static var liveValue: DebugDependency { DebugDependency() }
  public static var testValue: DebugDependency { .liveValue }
  public static var previewValue: DebugDependency { .liveValue }
}


public struct DebugDependency {
  public var stackDepth: StackDepth { .init() }
}

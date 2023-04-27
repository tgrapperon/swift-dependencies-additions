import Dependencies

extension DependencyValues {
  public var debug: DebugDependency {
    get { self[DebugDependency.self] }
    set { self[DebugDependency.self] = newValue }
  }
}

extension DebugDependency: DependencyKey {
  public static var liveValue: DebugDependency { DebugDependency(stackDepth: { StackDepth() }) }
  public static var testValue: DebugDependency { .liveValue }
  public static var previewValue: DebugDependency { .liveValue }

  public static var unimplemented: DebugDependency {
    DebugDependency(
      stackDepth: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.debug).stackDepth"#,
        placeholder: StackDepth()
      )
    )
  }
}

public struct DebugDependency: Sendable {
  
  var _stackDepth: @Sendable () -> StackDepth
  public var stackDepth: StackDepth { self._stackDepth() }
  
  init(stackDepth: @escaping @Sendable () -> StackDepth) {
    self._stackDepth = stackDepth
  }
}

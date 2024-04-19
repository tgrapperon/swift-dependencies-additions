import Dependencies

extension ReadWriteBinding {
  public static func unimplemented(
    _ description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
  public static func unimplemented(
    _ description: String,
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
}

extension ReadWriteProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadWriteProxy(
      .unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "", placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadWriteProxy(
      .unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
  }
}

extension ReadOnlyProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadOnlyProxy(
      XCTestDynamicOverlay.unimplemented(description, file: file, fileID: fileID, line: line))
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadOnlyProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

extension MainActorReadWriteBinding {
  public static func unimplemented(
    _ description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
  public static func unimplemented(
    _ description: String,
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
}

extension MainActorReadWriteProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadWriteProxy(
      .unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadWriteProxy(
      .unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
  }
}

extension MainActorReadOnlyProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadOnlyProxy(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadOnlyProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable () -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D, E) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

// Async
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable () async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D, E) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

// Throws
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable () throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D, E) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

// Async Throws
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable () async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D, E) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D, E) -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

// Async
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D, E) async -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

// Throws
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D, E) throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

// Async Throws
extension FunctionProxy {
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }

  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D, E) async throws -> Result {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

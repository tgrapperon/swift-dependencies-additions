import Dependencies
import IssueReporting

extension ReadWriteBinding {
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      IssueReporting.unimplemented(
        description,
        placeholder: () as! Value,
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
      IssueReporting.unimplemented(
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
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadWriteProxy(
      .unimplemented(
        description,
        placeholder: () as! Value,
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
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadOnlyProxy(
      IssueReporting.unimplemented(
        description,
        placeholder: () as! Value,
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
    ReadOnlyProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

extension MainActorReadWriteBinding {
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value: Sendable {
    let value = LockIsolated<@Sendable () -> Value>(
      IssueReporting.unimplemented(
        description,
        placeholder: () as! Value,
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
      IssueReporting.unimplemented(
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
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadWriteProxy(
      .unimplemented(
        description,
        placeholder: () as! Value,
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
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadOnlyProxy(
      value:
        IssueReporting.unimplemented(
          description,
          placeholder: () as! Value,
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
      IssueReporting.unimplemented(
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
    FunctionProxy(value: {
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
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
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable () async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @Sendable (A, B, C, D, E) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

extension FunctionProxy {
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }

  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }

  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }

  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }

  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
}

// Async
extension FunctionProxy {
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable () async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, D, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
        fileID: fileID,
        line: line
      )
    })
  }
  @available(*, unavailable, message: "Use .unimplemented(_:placeholder:)")
  public static func unimplemented<A, B, C, D, E, Result>(
    _ description: String = "",
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self where Value == @MainActor @Sendable (A, B, C, D, E) async -> Result {
    FunctionProxy({
      IssueReporting.unimplemented(
        description,
        placeholder: fatalError(),
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
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
      IssueReporting.unimplemented(
        description,
        fileID: fileID,
        line: line
      )
    })
  }
}

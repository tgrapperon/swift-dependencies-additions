import XCTestDynamicOverlay

private func check() async throws {
  func f(_ f: @autoclosure () -> String) {}
  func fa(_ f: @autoclosure () async -> String) async {}
  func ft(_ f: @autoclosure () throws -> String) throws {} 
  func fat(_ f: @autoclosure () async throws -> String) async throws {}

  f(unimplementedAutoclosure(placeholder: "")())
  await fa(unimplementedAutoclosure(placeholder: "")())
  try ft(unimplementedAutoclosure(placeholder: "")())
  try await fat(unimplementedAutoclosure(placeholder: "")())

  f(unimplementedAutoclosure()())
  await fa(unimplementedAutoclosure()())
  try ft(unimplementedAutoclosure()())
  try await fat(unimplementedAutoclosure()())
}

public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  placeholder: @autoclosure @escaping @Sendable () -> Result,
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () -> Result {
  unimplemented(description(), placeholder: placeholder(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  placeholder: @autoclosure @escaping @Sendable () -> Result,
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () async -> Result {
  unimplemented(description(), placeholder: placeholder(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  placeholder: @autoclosure @escaping @Sendable () -> Result,
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () throws -> Result {
  unimplemented(description(), placeholder: placeholder(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  placeholder: @autoclosure @escaping @Sendable () -> Result,
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () async throws -> Result {
  unimplemented(description(), placeholder: placeholder(), fileID: fileID, line: line)
}

public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () -> Result {
  unimplemented(description(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () async -> Result {
  unimplemented(description(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () throws -> Result {
  unimplemented(description(), fileID: fileID, line: line)
}

@_disfavoredOverload
public func unimplementedAutoclosure<Result>(
  _ description: @autoclosure @escaping @Sendable () -> String = "",
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> @Sendable () async throws -> Result {
  unimplemented(description(), fileID: fileID, line: line)
}

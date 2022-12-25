import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var decode: DataDecoder {
    get { self[DataDecoder.self] }
    set { self[DataDecoder.self] = newValue }
  }
}

extension DataDecoder: DependencyKey {
  public static var liveValue: DataDecoder { DataDecoder.json }
  public static var testValue: DataDecoder {
    XCTFail(#"Unimplemented: @Dependency(\.decode)"#)
    return .json
  }
}

public struct DataDecoder: Sendable {
  private let _decode: @Sendable (any Decodable.Type, Data) throws -> any Decodable
  private let _decodeAsync: @Sendable (any Decodable.Type, Data) async throws -> any Decodable

  public init(
    decode: @escaping @Sendable (any Decodable.Type, Data) throws -> any Decodable,
    async decodeAsync: (@Sendable (any Decodable.Type, Data) async throws -> any Decodable)? = nil
  ) {
    self._decode = decode
    self._decodeAsync = { @Sendable in try await decodeAsync?($0, $1) ?? decode($0, $1) }
  }

  public func callAsFunction<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try self._decode(type, data) as! T
  }

  public func callAsFunction<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T {
    try await self._decodeAsync(type, data) as! T
  }
}

extension DataDecoder {
  public init(_ decoder: JSONDecoder) {
    self.init {
      try decoder.decode($0, from: $1)
    }
  }
  public init(_ decoder: PropertyListDecoder) {
    self.init {
      try decoder.decode($0, from: $1)
    }
  }

  public static var json: DataDecoder {
    DataDecoder(JSONDecoder())
  }

  public static var plist: DataDecoder {
    DataDecoder(PropertyListDecoder())
  }
}

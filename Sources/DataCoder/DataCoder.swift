import Dependencies
import Foundation
import XCTestDynamicOverlay

// Used as
// @Dependency(\.encode) var encode
// @Dependency(\.decode) var decode
//
// let point = CGPoint(x: 2, y: 4)
// let data = try encode(point)
// let decoded = try decode(CGPoint.self, from: data)
//
// DependencyValues.withValues {
//   $0.encode = .plist(.binary)
//   $0.decode = .json
// } operation: {
//   …
// }

extension DependencyValues {
  public var decode: DataDecoder {
    get { self[DataDecoder.self] }
    set { self[DataDecoder.self] = newValue }
  }
  public var encode: DataEncoder {
    get { self[DataEncoder.self] }
    set { self[DataEncoder.self] = newValue }
  }
}

extension DataDecoder: DependencyKey {
  public static var liveValue: DataDecoder { DataDecoder.json }
  public static var testValue: DataDecoder {
    XCTFail(#"Unimplemented: @Dependency(\.decode)"#)
    return .json
  }
}

extension DataEncoder: DependencyKey {
  public static var liveValue: DataEncoder { DataEncoder.json }
  public static var testValue: DataEncoder {
    XCTFail(#"Unimplemented: @Dependency(\.encode)"#)
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

public struct DataEncoder: Sendable {
  private let _encode: @Sendable (any Encodable) throws -> Data
  private let _encodeAsync: @Sendable (any Encodable) async throws -> Data

  public init(
    encode: @escaping @Sendable (any Encodable) throws -> Data,
    async encodeAsync: (@Sendable (any Encodable) async throws -> Data)? = nil

  ) {
    self._encode = encode
    self._encodeAsync = { @Sendable in try await encodeAsync?($0) ?? encode($0) }
  }

  public func callAsFunction(_ value: some Encodable) throws -> Data {
    try self._encode(value)
  }
  
  public func callAsFunction(_ value: some Encodable) async throws -> Data {
    try await self._encodeAsync(value)
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

extension DataEncoder {
  public init(_ encoder: JSONEncoder) {
    self.init {
      try encoder.encode($0)
    }
  }
  public init(_ encoder: PropertyListEncoder) {
    self.init {
      try encoder.encode($0)
    }
  }

  public static var json: DataEncoder {
    let encoder = JSONEncoder()
    // The following can help with testing
    encoder.outputFormatting.insert(.sortedKeys)
    return DataEncoder(encoder)
  }

  public static func plist(_ outputFormat: PropertyListSerialization.PropertyListFormat = .xml)
    -> DataEncoder
  {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = outputFormat
    return DataEncoder(encoder)
  }
}

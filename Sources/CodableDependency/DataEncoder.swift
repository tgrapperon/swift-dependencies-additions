import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var encode: DataEncoder {
    get { self[DataEncoder.self] }
    set { self[DataEncoder.self] = newValue }
  }
}

extension DataEncoder: DependencyKey {
  public static var liveValue: DataEncoder { DataEncoder.json }
  public static var testValue: DataEncoder {
    XCTFail(#"Unimplemented: @Dependency(\.encode)"#)
    return .json
  }
}

public struct DataEncoder: Sendable {
  private let encode: @Sendable (any Encodable) throws -> Data

  public init(
    encode: @escaping @Sendable (any Encodable) throws -> Data
  ) {
    self.encode = encode
  }

  public func callAsFunction(_ value: some Encodable) throws -> Data {
    try self.encode(value)
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

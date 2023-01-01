import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  /// A ``DataEncoder`` that can encode a `Codable` value into a `Data` value.
  ///
  /// By default, `encode` produce JSON data, but this can be configured using
  /// ``DataEncoder/json``, ``DataEncoder/plist(_:)``, or by providing your own
  /// encoder.
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

/// A type that encodes `Encodable` values as `Data` values.
public struct DataEncoder: Sendable {
  private let encode: @Sendable (any Encodable) throws -> Data

  /// Creates a ``DataEncoder`` value from a closure you supply.
  public init(
    encode: @escaping @Sendable (any Encodable) throws -> Data
  ) {
    self.encode = encode
  }
 
  /// Returns a `Data`-encoded representation of the value you supply.
  public func callAsFunction(_ value: some Encodable) throws -> Data {
    try self.encode(value)
  }
}

extension DataEncoder {
  /// Creates a ``DataEncoder`` value from a `JSONEncoder` instance.
  public init(_ encoder: JSONEncoder) {
    self.init {
      try encoder.encode($0)
    }
  }
  /// Creates a ``DataEncoder`` value from a `PropertyListEncoder` instance.
  public init(_ encoder: PropertyListEncoder) {
    self.init {
      try encoder.encode($0)
    }
  }

  /// A ``DataEncoder`` that encodes instances of a data type as JSON objects.
  public static var json: DataEncoder {
    let encoder = JSONEncoder()
    // The following can help with testing
    encoder.outputFormatting.insert(.sortedKeys)
    return DataEncoder(encoder)
  }
  
  /// A ``DataEncoder`` that encodes instances of data types to a property list.
  public static func plist(_ outputFormat: PropertyListSerialization.PropertyListFormat = .xml)
    -> DataEncoder
  {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = outputFormat
    return DataEncoder(encoder)
  }
}

#if canImport(Combine)
import Combine
extension DataEncoder {
  /// Creates a ``DataEncoder`` value from a `TopLevelEncoder` instance.
  @_disfavoredOverload
  public init<E: TopLevelEncoder & Sendable>(_ encoder: E) where E.Output == Data {
    self.init {
      try encoder.encode($0)
    }
  }
}
#endif

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  /// A ``DataDecoder`` that can encode a `Codable` value into a `Data` value.
  ///
  /// By default, `decode` consumes JSON data, but this can be configured using
  /// ``DataDecoder/json``, ``DataDecoder/plist``, or by providing your own
  /// decoder.
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

/// A type that decodes `Decodable` values from `Data` values.
public struct DataDecoder: Sendable {
  private let decode: @Sendable (any Decodable.Type, Data) throws -> any Decodable

  /// Creates a ``DataDecoder`` value from a closure you supply.
  public init(
    decode: @escaping @Sendable (any Decodable.Type, Data) throws -> any Decodable
  ) {
    self.decode = decode
  }
  /// Returns a value of the type you specify, decoded from a `Data` value.
  public func callAsFunction<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try self.decode(type, data) as! T
  }
}

extension DataDecoder {
  /// Creates a ``DataDecoder`` value from a `JSONDecoder` instance.
  public init(_ decoder: JSONDecoder) {
    self.init {
      try decoder.decode($0, from: $1)
    }
  }
  /// Creates a ``DataDecoder`` value from a `PropertyListDecoder` instance.
  public init(_ decoder: PropertyListDecoder) {
    self.init {
      try decoder.decode($0, from: $1)
    }
  }

  /// A ``DataDecoder`` that decodes instances of a data type from JSON objects.
  public static var json: DataDecoder {
    DataDecoder(JSONDecoder())
  }

  /// A ``DataDecoder`` that decodes instances of data types from a property list.
  public static var plist: DataDecoder {
    DataDecoder(PropertyListDecoder())
  }
}

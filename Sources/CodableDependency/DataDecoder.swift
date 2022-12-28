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
  private let decode: @Sendable (any Decodable.Type, Data) throws -> any Decodable

  public init(
    decode: @escaping @Sendable (any Decodable.Type, Data) throws -> any Decodable
  ) {
    self.decode = decode
  }

  public func callAsFunction<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try self.decode(type, data) as! T
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

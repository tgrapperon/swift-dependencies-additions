import Compression
import Dependencies
import Foundation

extension DependencyValues {
  /// A ``Decompressor`` that can decompress a `Data` value that you supply.
  public var decompress: Decompressor {
    get { self[Decompressor.self] }
    set { self[Decompressor.self] = newValue }
  }
}

extension Decompressor: DependencyKey {
  public static var liveValue: Self {
    .default
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.decompress)"#)
    return .default
  }

  public static var `default`: Decompressor {
    Decompressor(
      defaultSync(.decompress),
      async: defaultAsync(.decompress)
    )
  }
}

/// A type that decompresses `Data` values.
public struct Decompressor: Sendable {
  private let decompress: @Sendable (Data, Algorithm) throws -> Data
  private let decompressAsync: @Sendable (Data, Algorithm) async throws -> Data

  /// Creates a ``Decompressor`` value by providing a closure that decompresses the provided
  /// data and algorithm.
  ///
  /// You can optionally specify an async version that may optimize the operation in async
  /// contexts. If no variant is specified, the sync version is used for sync and async calls.
  public init(
    _ decompress: @escaping @Sendable (Data, Algorithm) throws -> Data,
    async decompressAsync: (@Sendable (Data, Algorithm) async throws -> Data)? = nil
  ) {
    self.decompress = { @Sendable in try decompress($0, $1) }
    self.decompressAsync = { @Sendable in try await decompressAsync?($0, $1) ?? decompress($0, $1) }
  }

  /// Decompresses the provided data synchronously, using the provided algorithm.
  public func callAsFunction(
    _ data: Data,
    using algorithm: Algorithm = .zlib
  ) throws -> Data {
    try self.decompress(data, algorithm)
  }

  /// Decompresses the provided data asynchronously, using the provided algorithm.
  public func callAsFunction(
    _ data: Data,
    using algorithm: Algorithm = .zlib
  ) async throws -> Data {
    try await self.decompressAsync(data, algorithm)
  }
}

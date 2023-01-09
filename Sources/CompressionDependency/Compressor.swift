import Compression
import Dependencies
import Foundation

extension DependencyValues {
  /// A ``Compressor`` that can compress a `Data` value that you supply.
  public var compress: Compressor {
    get { self[Compressor.self] }
    set { self[Compressor.self] = newValue }
  }
}

extension Compressor: DependencyKey {
  public static var liveValue: Self {
    .default
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.compress)"#)
    return .default
  }

  public static var `default`: Compressor {
    Compressor(defaultSync(.compress), async: defaultAsync(.compress))
  }
}

/// A type that compresses `Data` values.
public struct Compressor: Sendable {
  private let compress: @Sendable (Data, Algorithm) throws -> Data
  private let compressAsync: @Sendable (Data, Algorithm) async throws -> Data

  /// Creates a ``Compressor`` value by providing a closure that compresses the provided
  /// data and algorithm.
  ///
  /// You can optionally specify an async version that may optimize the operation in async
  /// contexts. If no variant is specified, the sync version is used for sync and async calls.
  public init(
    _ compress: @escaping @Sendable (Data, Algorithm) throws -> Data,
    async compressAsync: (@Sendable (Data, Algorithm) async throws -> Data)? = nil
  ) {
    self.compress = { @Sendable in try compress($0, $1) }
    self.compressAsync = { @Sendable in try await compressAsync?($0, $1) ?? compress($0, $1) }
  }

  /// Compresses the provided data synchronously, using the provided algorithm.
  public func callAsFunction(
    _ data: Data,
    using algorithm:  @Sendable @autoclosure () -> Algorithm = .zlib
  ) throws -> Data {
    try self.compress(data, algorithm())
  }
  /// Compresses the provided data asynchronously, using the provided algorithm.
  public func callAsFunction(
    _ data: Data,
    using algorithm: @Sendable @autoclosure () -> Algorithm = .zlib
  ) async throws -> Data {
    try await self.compressAsync(data, algorithm())
  }
}

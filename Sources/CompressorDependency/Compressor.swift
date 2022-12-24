import Compression
import Dependencies
import Foundation

extension DependencyValues {
  public var compress: Compressor {
    get { self[Compressor.self] }
    set { self[Compressor.self] = newValue }
  }

  public var decompress: Decompressor {
    get { self[Decompressor.self] }
    set { self[Decompressor.self] = newValue }
  }
}

extension Compressor: DependencyKey {
  public static var liveValue: Self {
    Compressor(`default`(.compress))
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.compressor)"#)
    return Compressor(`default`(.compress))
  }
}

extension Decompressor: DependencyKey {
  public static var liveValue: Self {
    Decompressor(`default`(.decompress))
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.decompressor)"#)
    return Decompressor(`default`(.decompress))
  }
}

public struct Compressor: Sendable {
  private let compress: @Sendable (Data, Algorithm) async throws -> Data

  public init(
    _ compress: @escaping @Sendable (Data, Algorithm) async throws -> Data
  ) {
    self.compress = { @Sendable in try await compress($0, $1) }
  }

  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) async throws -> Data
  {
    try await self.compress(data, algorithm)
  }
}

public struct Decompressor: Sendable {
  private let decompress: @Sendable (Data, Algorithm) async throws -> Data
  public init(
    _ decompress: @escaping @Sendable (Data, Algorithm) async throws -> Data
  ) {
    self.decompress = { @Sendable in try await decompress($0, $1) }
  }
  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) async throws -> Data
  {
    try await self.decompress(data, algorithm)
  }
}

private func `default`(_ operation: FilterOperation) -> @Sendable (
  _ data: Data, _ algorithm: Algorithm
) async throws
  -> Data
{
  let operation = UncheckedSendable(operation)
  return { data, algorithm in
    let pageSize: Int = 512

    var processed = Data()
    var index = 0
    let count = data.count
    let inputFilter = try InputFilter(
      operation.wrappedValue,
      using: algorithm,
      bufferCapacity: max(65635, pageSize)
    ) {
      let rangeLength = min($0, count - index)
      let subdata = data[index..<index + rangeLength]
      index += rangeLength
      return subdata
    }
    while let page = try inputFilter.readData(ofLength: pageSize) {
      try Task.checkCancellation()
      await Task.yield()
      processed.append(page)
    }
    return processed
  }
}

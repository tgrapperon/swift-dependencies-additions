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
    Compressor(`default`(.compress), async: defaultAsync(.compress))
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.compressor)"#)
    return Compressor(`default`(.compress), async: defaultAsync(.compress))
  }
}

extension Decompressor: DependencyKey {
  public static var liveValue: Self {
    Decompressor(`default`(.decompress), async: defaultAsync(.decompress))
  }

  public static var testValue: Self {
    XCTFail(#"Unimplemented: @Dependency(\.decompressor)"#)
    return Decompressor(`default`(.decompress), async: defaultAsync(.decompress))
  }
}

public struct Compressor: Sendable {
  private let compress: @Sendable (Data, Algorithm) throws -> Data
  private let compressAsync: @Sendable (Data, Algorithm) async throws -> Data

  public init(
    _ compress: @escaping @Sendable (Data, Algorithm) throws -> Data,
    async compressAsync: (@Sendable (Data, Algorithm) async throws -> Data)? = nil
  ) {
    self.compress = { @Sendable in try compress($0, $1) }
    self.compressAsync = { @Sendable in try await compressAsync?($0, $1) ?? compress($0, $1) }
  }
  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) throws -> Data {
    try self.compress(data, algorithm)
  }
  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) async throws -> Data
  {
    try await self.compressAsync(data, algorithm)
  }
}

public struct Decompressor: Sendable {
  private let decompress: @Sendable (Data, Algorithm) throws -> Data
  private let decompressAsync: @Sendable (Data, Algorithm) async throws -> Data

  public init(
    _ decompress: @escaping @Sendable (Data, Algorithm) throws -> Data,
    async decompressAsync: (@Sendable (Data, Algorithm) async throws -> Data)? = nil
  ) {
    self.decompress = { @Sendable in try decompress($0, $1) }
    self.decompressAsync = { @Sendable in try await decompressAsync?($0, $1) ?? decompress($0, $1) }
  }
  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) throws -> Data {
    try self.decompress(data, algorithm)
  }
  public func callAsFunction(_ data: Data, using algorithm: Algorithm = .zlib) async throws -> Data
  {
    try await self.decompressAsync(data, algorithm)
  }
}

private func `default`(_ operation: FilterOperation) -> @Sendable (
  _ data: Data, _ algorithm: Algorithm
) throws
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
      processed.append(page)
    }
    return processed
  }
}

private func defaultAsync(_ operation: FilterOperation) -> @Sendable (
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

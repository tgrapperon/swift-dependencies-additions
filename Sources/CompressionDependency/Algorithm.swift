import Compression

/// A `Sendable` version of `Compression` algorithms.
public enum Algorithm: Sendable {
  /// LZFSE
  case lzfse
  /// Deflate (conforming to RFC 1951)
  case zlib
  /// LZ4 with simple frame encapsulation
  case lz4
  /// LZMA in a XZ container
  case lzma
  /// LZBITMAP
  case lzbitmap
  /// BROTLI
  case brotli

  public var systemValue: Compression.Algorithm {
    switch self {
    case .lzfse:
      return .lzfse
    case .zlib:
      return .zlib
    case .lz4:
      return .lz4
    case .lzma:
      return .lzma
    case .lzbitmap:
      return .lzbitmap
    case .brotli:
      return .brotli
    }
  }
  public init(_ algorithm: Compression.Algorithm) {
    switch algorithm {
    case .lzfse:
      self = .lzfse
    case .zlib:
      self = .zlib
    case .lz4:
      self = .lz4
    case .lzma:
      self = .lzma
    case .lzbitmap:
      self = .lzbitmap
    case .brotli:
      self = .brotli
    @unknown default:
      fatalError("Unknow algorithm")
    }
  }
}

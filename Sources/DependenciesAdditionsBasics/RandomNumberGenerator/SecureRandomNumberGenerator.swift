#if canImport(Security)
import Dependencies
import Security

extension RandomNumberGenerator where Self == SecureRandomNumberGenerator {
  /// A cryptographically secure random number generator
  public static var secure: SecureRandomNumberGenerator { .init() }
}

extension WithRandomNumberGenerator {
  /// A `WithRandomNumberGenerator` using a cryptographically secure random number generator
  public static var secure: WithRandomNumberGenerator { .init(.secure) }
}

/// A cryptographically secure random number generator
public struct SecureRandomNumberGenerator: RandomNumberGenerator, Sendable {
  /// Generates a cryptographically secure `UInt64` number.
  public func next() -> UInt64 {
    var result: UInt64 = 0
    let status = withUnsafeMutablePointer(to: &result) {
      $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt64>.size) {
        SecRandomCopyBytes(nil, MemoryLayout<UInt64>.size, $0)
      }
    }
    guard status == errSecSuccess else {
      fatalError("Failed to generate a cryptographically secure random number.")
    }
    return result
  }
}
#endif

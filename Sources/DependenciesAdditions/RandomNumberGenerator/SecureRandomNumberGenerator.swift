#if canImport(Security)
  import Dependencies
  import Security
  // Allows DependencyValues.withValue(\.withRandomNumberGenerator, .init(.secure)) { … }
  extension RandomNumberGenerator where Self == SecureRandomNumberGenerator {
    public static var secure: SecureRandomNumberGenerator { .init() }
  }

  extension WithRandomNumberGenerator {
    public static var secure: WithRandomNumberGenerator { .init(.secure) }
  }

  public struct SecureRandomNumberGenerator: RandomNumberGenerator, Sendable {
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

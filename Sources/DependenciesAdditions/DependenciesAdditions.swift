import Dependencies
import Foundation
// TODO: Organize

extension DateGenerator {
  /// A generator that generates dates in incrementing order.
  ///
  /// For example:
  ///
  /// ```swift
  /// let generate = DateGenerator.incrementing()
  /// generate()  // 2001-01-01 00:00:00 +0000
  /// generate()  // 2001-01-01 00:00:01 +0000
  /// generate()  // 2001-01-01 00:00:02 +0000
  /// ```
  /// - Parameters:
  ///   - by: The duration between successive dates, in seconds. The default is 1s.
  ///   - from: The initial date. The default is 00:00:00 UTC on 1 January 2001.
  /// - Returns: A generator that returns successive dates separated by a constant interval.
  public static func incrementing(
    by interval: TimeInterval = 1.0,
    from reference: Date = Date(timeIntervalSinceReferenceDate: 0)
  ) -> Self {
    let generator = IncrementingDateGenerator(interval: interval, reference: reference)
    return Self { generator() }
  }
}

private final class IncrementingDateGenerator: @unchecked Sendable {
  private let lock = NSLock()
  private var steps = 0
  let interval: TimeInterval
  let reference: Date
  
  init(interval: TimeInterval, reference: Date) {
    self.interval = interval
    self.reference = reference
  }
  func callAsFunction() -> Date {
    self.lock.lock()
    defer {
      self.steps += 1
      self.lock.unlock()
    }
    return Date(timeInterval: TimeInterval(self.steps) * self.interval, since: self.reference)
  }
}
extension DateGenerator {
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public static func ticking(
    from reference: Date = Date(timeIntervalSinceReferenceDate: 0), // or .now?
    with clock: (KeyPath<DependencyValues, any Clock<Duration>>) = \.continuousClock
  ) -> DateGenerator {
    @Dependency(clock) var clock;
    let referenceNow: LockIsolated<(any InstantProtocol)?> = .init(nil)
    
    return DateGenerator {
      if referenceNow.value == nil {
        referenceNow.setValue(clock.now as any InstantProtocol)
        return reference
      }

      let timeInterval = clock.approximateTimeInterval(
        between: referenceNow.value!,
        and: clock.now as any InstantProtocol
      )
      return reference.addingTimeInterval(timeInterval)
    }
  }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
extension Clock where Duration == Swift.Duration {
  fileprivate func approximateTimeInterval(
    between first: any InstantProtocol,
    and second: any InstantProtocol
  ) -> TimeInterval {
    let duration = (first as! Instant).duration(to: second as! Instant)
    return TimeInterval(duration.components.seconds)
    + TimeInterval(duration.components.attoseconds) * 1e-18
  }
}


extension RandomNumberGenerator where Self == SystemRandomNumberGenerator {
  public static var system: SystemRandomNumberGenerator { .init() }
}

#if canImport(Security)
  import Security
  // Allows DependencyValues.withValue(\.withRandomNumberGenerator, .init(.secure)) { … }
  extension RandomNumberGenerator where Self == SecureRandomNumberGenerator {
    public static var secure: SecureRandomNumberGenerator { .init() }
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

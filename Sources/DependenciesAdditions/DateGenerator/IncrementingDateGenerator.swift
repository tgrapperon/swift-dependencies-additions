@_exported import Dependencies
import Foundation

extension DateGenerator {
  /// A `Date` generator that generates dates in incrementing order.
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

private final class IncrementingDateGenerator: Sendable {
  private let steps = LockIsolated(0)
  let interval: TimeInterval
  let reference: Date
  
  init(interval: TimeInterval, reference: Date) {
    self.interval = interval
    self.reference = reference
  }
  func callAsFunction() -> Date {
    self.steps.withValue {
      $0 += 1
      return Date(timeInterval: TimeInterval($0) * self.interval, since: self.reference)
    }
  }
}

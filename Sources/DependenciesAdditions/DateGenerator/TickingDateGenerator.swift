import Dependencies
import Foundation

extension DateGenerator {
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  /// A `Date` generator that this driven by a `Clock`.
  ///
  /// The generator will create a point of reference in time the first time it generates a `Date`.
  /// Subsequent dates will be generated according to the time that has passed using the provided
  /// clock.
  ///
  /// - Note: As this generator is stateful, it is recommened to create and store the value
  /// somewhere in order to produce meaninful results if you're using it as some `Reducer`'s
  /// dependency in TCA.
  ///
  /// - Parameters:
  ///   - originOfTime: The reference date that is returned the first time this generator produces
  ///   a `date`, or 00:00:00 UTC on 1 January 2001 by default.
  ///   - clock: The `KeyPath` of a `Clock` dependency that is used to measure time between
  ///   generated dates, or `.\continuousClock` by default.
  /// - Returns: A `DateGenerator` that generates dates using a `Clock`.
  public static func ticking(
    from originOfTime: Date = Date(timeIntervalSinceReferenceDate: 0),  // or .now?
    with clock: (KeyPath<DependencyValues, any Clock<Duration>>) = \.continuousClock
  ) -> DateGenerator {
    @Dependency(clock) var clock
    let referenceNow: LockIsolated<(any InstantProtocol)?> = .init(nil)

    return DateGenerator {
      if referenceNow.value == nil {
        referenceNow.setValue(clock.now as any InstantProtocol)
        return originOfTime
      }

      let timeInterval = clock.approximateTimeInterval(
        between: referenceNow.value!,
        and: clock.now as any InstantProtocol
      )
      return originOfTime.addingTimeInterval(timeInterval)
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

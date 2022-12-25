import Dependencies
import Foundation

extension DateGenerator {
  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
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

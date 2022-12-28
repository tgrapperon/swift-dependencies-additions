@_exported import Dependencies

extension RandomNumberGenerator where Self == SystemRandomNumberGenerator {
  /// The system random number generator.
  public static var system: SystemRandomNumberGenerator { .init() }
}

extension WithRandomNumberGenerator {
  /// A `WithRandomNumberGenerator` using the system random number generator
  public static var system: WithRandomNumberGenerator { .init(.system) }
}

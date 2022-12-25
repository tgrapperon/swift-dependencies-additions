import Dependencies

extension RandomNumberGenerator where Self == SystemRandomNumberGenerator {
  public static var system: SystemRandomNumberGenerator { .init() }
}

extension WithRandomNumberGenerator {
  public static var system: WithRandomNumberGenerator { .init(.system) }
}

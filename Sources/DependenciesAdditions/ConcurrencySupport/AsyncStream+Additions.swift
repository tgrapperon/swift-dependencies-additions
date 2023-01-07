extension AsyncStream {
  /// Produces an `AsyncStream` from an async `AsyncSequence` by awaiting and then consuming the
  /// sequence till it terminates, ignoring any failure.
  ///
  /// Useful as a kind of type eraser for actor-isolated live `AsyncSequence`-based dependencies,
  /// that also erases the `async` extraction.
  public init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S) rethrows
  where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = try? await sequence().makeAsyncIterator()
      }
      return try? await iterator?.next()
    }
  }
}

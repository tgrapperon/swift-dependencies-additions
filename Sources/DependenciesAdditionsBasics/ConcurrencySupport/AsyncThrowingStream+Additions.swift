extension AsyncThrowingStream where Failure == Error {
  /// Produces an `AsyncThrowingStream` from an async `AsyncSequence` by awaiting and then consuming
  /// the sequence till it terminates, rethrowing any failure.
  ///
  /// Useful as a kind of type eraser for actor-isolated live `AsyncSequence`-based dependencies, that
  /// also erases the `async` extraction.
  public init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S)
  where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = try await sequence().makeAsyncIterator()
      }
      return try await iterator?.next()
    }
  }
}

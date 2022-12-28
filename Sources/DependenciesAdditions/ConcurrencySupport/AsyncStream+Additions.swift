
extension AsyncStream {
  public init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S) throws
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

extension AsyncStream  {
  public init<S: Sequence>(_ sequence: @escaping () async throws -> S)
  where S.Element == Element {
    var iterator: S.Iterator?
    self.init {
      if iterator == nil {
        iterator = try? await sequence().makeIterator()
      }
      return iterator?.next()
    }
  }
}

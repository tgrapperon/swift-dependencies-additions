import Dependencies
import Foundation

extension AsyncStream {
  public init<S: AsyncSequence>(_ sequence: @escaping () async -> S)
  where S.Element == Element {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = await sequence().makeAsyncIterator()
      }
      return try? await iterator?.next()
    }
  }
}

extension AsyncThrowingStream where Failure == Error {
  public init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S) throws
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

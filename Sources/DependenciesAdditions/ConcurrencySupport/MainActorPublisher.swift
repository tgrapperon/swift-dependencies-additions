import Combine
import Dependencies
import Foundation

extension AsyncSequence {
  @_spi(Internals)
  @MainActor
  public func mainActorPublisher() -> AnyPublisher<Element, Never>
  where Self: Sendable, Element: Sendable {
    let subject = CurrentValueSubject<Element?, Never>(.none)
    
    let task = Task {
      do {
        for try await element in self {
          subject.send(element)
        }
      } catch {
        subject.send(completion: .finished)
      }
    }
    
    return subject.handleEvents(receiveCancel: {
      task.cancel()
    })
    .compactMap { $0 }
    .eraseToAnyPublisher()
  }
}

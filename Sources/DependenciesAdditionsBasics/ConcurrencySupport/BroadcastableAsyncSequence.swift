import Dependencies
import Foundation

#if canImport(Combine)
  @preconcurrency import Combine
#endif

public protocol BroadcastableAsyncSequence: AsyncSequence {}

#if canImport(Combine)
  extension BroadcastableAsyncSequence {
    @_spi(Internals) public func publisher() -> AnyPublisher<Element, Never>
    where Self: Sendable, Self.Element: Sendable {
      let subject = CurrentValueSubject<Element?, Never>(.none)

      let task = Task { @MainActor in
        do {
          for try await element in self {
            subject.send(element)
          }
        } catch {
          subject.send(completion: .finished)
        }
      }

      return subject.handleEvents(
        receiveCancel: {
          task.cancel()
        })
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
  }
#endif

extension BroadcastableAsyncSequence where Self: Sendable {
  public func forEach(
    priority: TaskPriority? = nil,
    @_inheritActorContext perform: @escaping @Sendable (Element) async -> Void
  ) -> AnyCancellableTask {
    Task(priority: priority) {
      do {
        for try await element in self {
          await perform(element)
        }
      } catch {}
    }.eraseToAnyCancellableTask()
  }
}
#if canImport(Combine)
  extension BroadcastableAsyncSequence where Self: Sendable, Self.Element: Sendable {
    /// Assigns each element from an async sequence to a property on an object.
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign.
    ///   - object: The object that contains the property. The subscriber assigns the object’s
    ///   property every time it receives a new value.
    /// - Returns: An AnyCancellable instance. Call cancel() on this instance when you no longer want
    /// the publisher to automatically assign the property. Deinitializing this instance will also
    /// cancel automatic assignment.
    @_disfavoredOverload
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root)
      -> AnyCancellable
    {
      self.publisher().assign(to: keyPath, on: object)
    }

    /// Assigns each element from an async sequence to a property on an object.
    ///
    /// The assign(to:) operator manages the life cycle of the subscription, canceling the
    /// subscription automatically when the Published instance deinitializes. Because of this, the
    /// ``BroadcastableAsyncSequence/assign(to:)-nymd`` operator doesn’t return an `AnyCancellable`
    /// that you’re responsible for like ``BroadcastableAsyncSequence/assign(to:on:)-41l64`` does.
    ///
    /// - Parameter published: A property marked with the @Published attribute, which receives and
    /// republishes all elements received from the upstream publisher.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    @_disfavoredOverload
    public func assign(to published: inout Published<Element>.Publisher) {
      self.publisher().assign(to: &published)
    }

    /// Assigns each element from an async sequence to a property on an object.
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign.
    ///   - object: The object that contains the property. The subscriber assigns the object’s
    ///   property every time it receives a new value.
    /// - Returns: An AnyCancellable instance. Call cancel() on this instance when you no longer want
    /// the publisher to automatically assign the property. Deinitializing this instance will also
    /// cancel automatic assignment.
    @_disfavoredOverload
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element?>, on object: Root)
      -> AnyCancellable
    {
      self.publisher().map(Optional.some).assign(to: keyPath, on: object)
    }

    /// Assigns each element from an async sequence to a property on an object.
    ///
    /// The assign(to:) operator manages the life cycle of the subscription, canceling the
    /// subscription automatically when the Published instance deinitializes. Because of this, the
    /// ``BroadcastableAsyncSequence/assign(to:)-6rn38`` operator doesn’t return an `AnyCancellable`
    /// that you’re responsible for like ``BroadcastableAsyncSequence/assign(to:on:)-6egqj`` does.
    ///
    /// - Parameter published: A property marked with the @Published attribute, which receives and
    /// republishes all elements received from the upstream publisher.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    @_disfavoredOverload
    public func assign(to published: inout Published<Element?>.Publisher) {
      self.publisher().map(Optional.some).assign(to: &published)
    }
  }
#endif

extension AsyncMapSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncFilterSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncCompactMapSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncDropFirstSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncDropWhileSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncFlatMapSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncPrefixSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}
extension AsyncPrefixWhileSequence: BroadcastableAsyncSequence
where Base: BroadcastableAsyncSequence {}

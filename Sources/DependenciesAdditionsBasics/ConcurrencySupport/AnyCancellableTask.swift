import Foundation

/// A reference type that ties the cancellation of an operation to lifetime of its reference.
/// Like `Combine`'s `AnyCancellable`, if you release this value, the operation is automatically
/// cancelled.
public final class AnyCancellableTask: Sendable, Hashable {
  let _cancel: @Sendable () -> Void
  let id: UUID = UUID()
  /// Initializes the cancellable object with the given cancel-time closure.
  public init(_ cancel: @escaping @Sendable () -> Void) {
    self._cancel = cancel
  }
  deinit {
    cancel()
  }
  /// Cancels the activity.
  func cancel() {
    _cancel()
  }
  public static func == (lhs: AnyCancellableTask, rhs: AnyCancellableTask) -> Bool {
    lhs.id == rhs.id
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  /// Stores this type-erasing cancellable instance in the specified collection.
  public func store<C>(in collection: inout C)
  where C: RangeReplaceableCollection, C.Element == AnyCancellableTask {
    collection.append(self)
  }
  /// Stores this type-erasing cancellable instance in the specified set.
  public func store(in set: inout Set<AnyCancellableTask>) {
    set.insert(self)
  }
}

extension Task {
  /// Stores this task as an erased `AnyCancellebleTask` in the specified collection.
  ///
  /// This helper automatically wraps this `Task` into an ``AnyCancellableTask`` and store's it
  /// in the specified collection.
  public func store<C>(in collection: inout C)
  where C: RangeReplaceableCollection, C.Element == AnyCancellableTask {
    collection.append(self.eraseToAnyCancellableTask())
  }
  /// Stores this as an erased `AnyCancellebleTask` in the specified set.
  ///
  /// This helper automatically wraps this `Task` into an ``AnyCancellableTask`` and store's it
  /// in the specified set.
  public func store(in set: inout Set<AnyCancellableTask>) {
    set.insert(self.eraseToAnyCancellableTask())
  }

  /// A type-erasing cancellable object that cancels the task when canceled.
  public func eraseToAnyCancellableTask() -> AnyCancellableTask {
    AnyCancellableTask { self.cancel() }
  }
}

#if canImport(Combine)
  import Combine
  extension AnyCancellableTask {
    /// Converts an ``AnyCancellableTask`` into a `AnyCancellable`.
    ///
    /// This operation allows task cancellable to share the same cancellable repository as `Combine`
    /// publishers.
    public func eraseToAnyCancellable() -> AnyCancellable {
      AnyCancellable(self._cancel)
    }
  }

  extension Task {
    /// Stores this task as an erased `AnyCancelleble` in the specified collection.
    ///
    /// This helper automatically wraps this `Task` into an ``AnyCancellable`` and store's it
    /// in the specified collection.
    public func store<C>(in collection: inout C)
    where C: RangeReplaceableCollection, C.Element == AnyCancellable {
      collection.append(self.eraseToAnyCancellable())
    }
    /// Stores this task as an erased `AnyCancelleble` in the specified set.
    ///
    /// This helper automatically wraps this `Task` into an ``AnyCancellable`` and store's it
    /// in the specified set.
    public func store(in set: inout Set<AnyCancellable>) {
      set.insert(self.eraseToAnyCancellable())
    }
    /// A type-erasing cancellable object that cancels the task when canceled.
    public func eraseToAnyCancellable() -> AnyCancellable {
      AnyCancellable { self.cancel() }
    }
  }

#endif

@preconcurrency import CoreData
import Dependencies
import DependenciesAdditions
import Foundation

public enum ScheduledTaskType {
  case immediate
  case enqueued
}

public struct FetchedResult<ResultType: NSManagedObject>: Identifiable, Sendable, Hashable {
  public let id: NSManagedObjectID
  public let context: NSManagedObjectContext
  var result: ResultType { self.context.object(with: self.id) as! ResultType }
  var token: UUID?
  init(id: NSManagedObjectID, context: NSManagedObjectContext, token: UUID? = nil) {
    self.id = id
    self.context = context
  }
}

extension FetchedResult {
  @discardableResult
  public func withValue<T>(perform: (ResultType) -> T) -> T {
    var result: Swift.Result<T, Never>?
    self.context.performAndWait {
      result = .success(perform(self.result))
    }
    switch result! {
    case let .success(value):
      return value
    }
  }

  @discardableResult
  public func withValue<T>(perform: (ResultType) throws -> T) throws -> T {
    var result: Swift.Result<T, Error>?
    self.context.performAndWait {
      result = .init(catching: { try perform(self.result) })
    }
    return try result!.get()
  }

  @discardableResult
  public func withValue<T>(
    schedule: ScheduledTaskType = .immediate, perform: @escaping (ResultType) -> T
  ) async -> T {
    return await withCheckedContinuation { continuation in
      switch schedule {
      case .immediate:
        continuation.resume(returning: self.withValue(perform: perform))
      case .enqueued:
        self.context.perform {
          continuation.resume(returning: perform(self.result))
        }
      }
    }
  }

  @discardableResult
  public func withValue<T>(
    schedule: ScheduledTaskType = .immediate, perform: @escaping (ResultType) throws -> T
  ) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
      switch schedule {
      case .immediate:
        continuation.resume(
          with: .init {
            try self.withValue(perform: perform)
          })
      case .enqueued:
        self.context.perform {
          continuation.resume(
            with: .init {
              try perform(self.result)
            })
        }
      }
    }
  }
}

public struct FetchRequest {
  @Dependency(\.persistentContainer) var persistentContainer
  
  init() {}
  
  @MainActor
  public func callAsFunction<ResultType: NSManagedObject>(
    predicate: NSPredicate,
    sortDescriptors: [NSSortDescriptor],
    context: NSManagedObjectContext? = nil
  ) -> AsyncThrowingStream<Results<ResultType>, Error> {
    let context = context ?? persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<ResultType>(entityName: String(describing: ResultType.self))
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    if fetchRequest.sortDescriptors!.isEmpty {
      fetchRequest.sortDescriptors?.append(
        .init(key: "objectID", ascending: true)
      )
    }
    return stream(fetchRequest: fetchRequest, context: context)
  }

  @MainActor
  public func callAsFunction<SectionIdentifier: Hashable, ResultType: NSManagedObject>(
    predicate: NSPredicate,
    sortDescriptors: [NSSortDescriptor],
    sectionIdentifier: KeyPath<ResultType, SectionIdentifier>,
    context: NSManagedObjectContext? = nil
  ) -> AsyncThrowingStream<SectionedResults<SectionIdentifier, ResultType>, Error> {
    let context = context ?? persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<ResultType>(entityName: String(describing: ResultType.self))
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors

    if fetchRequest.sortDescriptors?.contains(where: { $0.keyPath == sectionIdentifier }) != true {
      fetchRequest.sortDescriptors?.append(.init(keyPath: sectionIdentifier, ascending: true))
    }

    return stream(
      fetchRequest: fetchRequest, sectionIdentifier: sectionIdentifier, context: context
    )
  }
}

extension AsyncThrowingStream {
  public var first: Element? {
    get async throws {
      var iterator = makeAsyncIterator()
      return try await iterator.next()
    }
  }
}

extension FetchRequest {
  public struct SectionedResults<SectionIdentifier: Hashable & Sendable, Element: NSManagedObject>:
    Sendable, Hashable
  {
    public struct Section: Hashable, Identifiable, Sendable {
      public let id: SectionIdentifier
      let results: [FetchedResult<Element>]
    }

    let sections: [Section]
  }
}

extension FetchRequest {
  public struct Results<ResultType: NSManagedObject>: Hashable, Sendable {
    let values: [FetchedResult<ResultType>]
  }
}

extension FetchRequest.Results: BidirectionalCollection {
  public var startIndex: Int { values.startIndex }
  public var endIndex: Int { values.endIndex }

  public subscript(position: Int) -> FetchedResult<ResultType> {
    values[position]
  }

  public func index(after i: Int) -> Int {
    values.index(after: i)
  }

  public func index(before i: Int) -> Int {
    values.index(before: i)
  }
}

extension FetchRequest.SectionedResults: RandomAccessCollection {
  public var startIndex: Int { sections.startIndex }
  public var endIndex: Int { sections.endIndex }

  public subscript(position: Int) -> Section {
    sections[position]
  }

  public func index(after i: Int) -> Int {
    sections.index(after: i)
  }

  public func index(before i: Int) -> Int {
    sections.index(before: i)
  }
}

extension FetchRequest.SectionedResults.Section: RandomAccessCollection {
  public var startIndex: Int { results.startIndex }
  public var endIndex: Int { results.endIndex }

  public subscript(position: Int) -> FetchedResult<Element> {
    results[position]
  }

  public func index(after i: Int) -> Int {
    results.index(after: i)
  }

  public func index(before i: Int) -> Int {
    results.index(before: i)
  }
}

extension FetchRequest {
  func stream<T: NSManagedObject>(
    fetchRequest: NSFetchRequest<T>,
    context: NSManagedObjectContext
  ) -> AsyncThrowingStream<Results<T>, Error> {
    AsyncThrowingStream<Results<T>, Error> { continuation in
      let context = UncheckedSendable(context)
      let fetchRequest = UncheckedSendable(fetchRequest.copy() as! NSFetchRequest<T>)
      let currentValue = LockIsolated(Results<T>(values: []))
      @Sendable
      func fetchResults(updated: Set<NSManagedObjectID> = []) {
        context.wrappedValue.perform {
          do {
            try currentValue.withValue { currentValue in
              var tokens = [NSManagedObjectID: UUID]()
              for value in currentValue {
                tokens[value.id] = value.token
              }
              tokens = tokens.filter { !updated.contains($0.key) }

              let results = try context.wrappedValue.fetch(fetchRequest.wrappedValue)
              currentValue = .init(
                values:
                  results.map {
                    FetchedResult(
                      id: $0.objectID,
                      context: context.wrappedValue,
                      token: tokens[$0.objectID]
                    )
                  }
              )
              continuation.yield(currentValue)
            }
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }

      let observer = ManagedObjectUpdatesObserver(
        context: context.wrappedValue,
        objectsDidChange: fetchResults(updated:)
      )

      fetchResults()

      continuation.onTermination = { [observer] _ in
        NotificationCenter.default.removeObserver(
          observer,
          name: .NSManagedObjectContextObjectsDidChange,
          object: context
        )
      }
    }
  }

  func stream<SectionIdentifier: Hashable & Sendable, T: NSManagedObject>(
    fetchRequest: NSFetchRequest<T>,
    sectionIdentifier: KeyPath<T, SectionIdentifier>,
    context: NSManagedObjectContext
  ) -> AsyncThrowingStream<SectionedResults<SectionIdentifier, T>, Error> {
    AsyncThrowingStream<SectionedResults<SectionIdentifier, T>, Error> { continuation in
      let context = UncheckedSendable(context)
      let fetchRequest = UncheckedSendable(fetchRequest.copy() as! NSFetchRequest<T>)
      let currentValue = LockIsolated(SectionedResults<SectionIdentifier, T>(sections: []))
      let sectionIdentifier = UncheckedSendable(sectionIdentifier)
      @Sendable
      func fetchResults(updated: Set<NSManagedObjectID> = []) {
        context.wrappedValue.perform {
          do {
            try currentValue.withValue { currentValue in
              var tokens = [NSManagedObjectID: UUID]()
              for section in currentValue.sections {
                for value in section {
                  tokens[value.id] = value.token
                }
              }
              tokens = tokens.filter { !updated.contains($0.key) }

              let results = try context.wrappedValue.fetch(fetchRequest.wrappedValue)

              currentValue = SectionedResults<SectionIdentifier, T>(
                sections:
                  results
                  .chunkedOn(keyPath: sectionIdentifier.wrappedValue)
                  .map {
                    SectionedResults<SectionIdentifier, T>.Section(
                      id: $0.0,
                      results: $0.1.map {
                        FetchedResult(
                          id: $0.objectID,
                          context: context.wrappedValue,
                          token: tokens[$0.objectID, default: UUID()]
                        )
                      }
                    )
                  }
              )

              continuation.yield(currentValue)
            }
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }

      let observer = ManagedObjectUpdatesObserver(
        context: context.wrappedValue,
        objectsDidChange: fetchResults(updated:)
      )

      fetchResults()

      continuation.onTermination = { [observer] _ in
        NotificationCenter.default.removeObserver(
          observer,
          name: .NSManagedObjectContextObjectsDidChange,
          object: context
        )
      }
    }
  }

  fileprivate final class ManagedObjectUpdatesObserver: NSObject, Sendable {
    let objectsDidChange: @Sendable (_ updated: Set<NSManagedObjectID>) -> Void
    init(
      context: NSManagedObjectContext,
      objectsDidChange: @escaping @Sendable (_ updated: Set<NSManagedObjectID>) -> Void
    ) {
      self.objectsDidChange = objectsDidChange
      super.init()
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextObjectsDidChange(notification:)),
        name: .NSManagedObjectContextObjectsDidChange,
        object: context
      )
    }

    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
      guard
        let userInfo = notification.userInfo,
        let context = notification.object as? NSManagedObjectContext
      else { return }

      var shouldRefetch = false

      if (userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>)?.isEmpty == false {
        shouldRefetch = true
      }
      if (userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>)?.isEmpty == false {
        shouldRefetch = true
      }
      var updated = Set<NSManagedObjectID>()
      if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
        updated.formUnion(updates.map(\.objectID))
        shouldRefetch = !updates.isEmpty
      }
      if shouldRefetch {
        context.perform {
          self.objectsDidChange(updated)
        }
      }
    }
  }
}

extension Array {
  func chunkedOn<Value: Equatable>(keyPath: KeyPath<Element, Value>) -> [(Value, [Element])] {
    self.reduce(into: [(Value, [Element])]()) { partialResult, element in
      let value = element[keyPath: keyPath]
      if partialResult.last?.0 == value {
        partialResult[partialResult.count - 1].1.append(element)
      } else {
        partialResult.append((value, [element]))
      }
    }
  }
}

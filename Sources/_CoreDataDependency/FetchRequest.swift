#if canImport(CoreData)
  @preconcurrency import CoreData
  @_exported import Dependencies
  @_exported import DependenciesAdditionsBasics
  import Foundation
  @_spi(Internals)@_exported import PersistentContainerDependency

  extension NSFetchRequestResult where Self: NSManagedObject {
    public typealias Fetched = _CoreDataDependency.AnyFetched<Self>
    public typealias FetchedResults = PersistentContainer
      .FetchRequest.Results<Self, ViewContext>
    public typealias AnyFetchedResults<Context: ManagedObjectContext> = PersistentContainer
      .FetchRequest.Results<Self, Context>
    public typealias SectionedFetchedResults<
      SectionIdentifier: Hashable
    > = PersistentContainer
      .FetchRequest.SectionedResults<SectionIdentifier, Self, ViewContext>
    public typealias AnySectionedFetchedResults<
      SectionIdentifier: Hashable, Context: ManagedObjectContext
    > = PersistentContainer
      .FetchRequest.SectionedResults<SectionIdentifier, Self, Context>
  }

  @dynamicMemberLookup
  public struct _AnyFetched<ManagedObject: NSManagedObject, Context: ManagedObjectContext>:
    Identifiable, Sendable, Hashable
  {
    public let id: NSManagedObjectID
    public let context: Context
    var token: UUID?
  }

  public typealias Fetched<ManagedObject: NSManagedObject> = _AnyFetched<ManagedObject, ViewContext>
  public typealias AnyFetched<ManagedObject: NSManagedObject> = _AnyFetched<
    ManagedObject, AnyManagedObjectContext
  >

  extension _AnyFetched where Context == ViewContext {
    @MainActor
    var mainActorContext: NSManagedObjectContext {
      self.context._managedObjectContext.wrappedValue
    }
    @MainActor
    var object: ManagedObject {
      self.mainActorContext.object(with: self.id) as! ManagedObject
    }
    @MainActor
    public subscript<Value>(dynamicMember keyPath: KeyPath<ManagedObject, Value>) -> Value {
      self.object[keyPath: keyPath]
    }
  }

  extension _AnyFetched where Context == ViewContext {
    public var editor: Editor {
      get { .init(fetched: self) }
      set { self = newValue.fetched }
    }

    @dynamicMemberLookup
    public struct Editor {
      var fetched: Fetched<ManagedObject>

      @MainActor
      public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ManagedObject, Value>) -> Value
      {
        get {
          self.fetched.object[keyPath: keyPath]
        }
        set {
          var object = self.fetched.object
          object[keyPath: keyPath] = newValue
          self.fetched.token = .init()
          self.fetched.mainActorContext.processPendingChanges()
        }
      }
    }
  }

  extension _AnyFetched where Context == ViewContext {
    @MainActor
    @discardableResult
    public func withManagedObject<T>(perform operation: @MainActor (ManagedObject) throws -> T)
      rethrows -> T
    {
      try operation(self.object)
    }

    @MainActor
    @discardableResult
    public func withManagedObjectContext<T>(
      perform operation: @MainActor (NSManagedObjectContext) throws -> T
    )
      rethrows -> T
    {
      try operation(self.context._managedObjectContext.wrappedValue)
    }
  }

  extension _AnyFetched where Context == AnyManagedObjectContext {
    var unsafeContext: NSManagedObjectContext {
      self.context._managedObjectContext.wrappedValue
    }
    var object: ManagedObject {
      self.unsafeContext.object(with: self.id) as! ManagedObject
    }
  }

  extension _AnyFetched where Context == AnyManagedObjectContext {
    @available(*, unavailable, message: "Use `withManagedObject { object in … }`")
    public subscript<Value>(dynamicMember keyPath: KeyPath<ManagedObject, Value>) -> Value {
      self.object[keyPath: keyPath]
    }

    @discardableResult
    public func withManagedObject<T: Sendable>(perform operation: (ManagedObject) throws -> T)
      async throws -> T
    {
      try await self.context.perform {
        try operation(self.object)
      }
    }

    @discardableResult
    public func withManagedObject<T: Sendable>(perform operation: (ManagedObject) -> T)
      async -> T
    {
      await self.context.perform {
        operation(self.object)
      }
    }

    @discardableResult
    public func withManagedObjectContext<T: Sendable>(
      perform operation: (NSManagedObjectContext) throws -> T
    )
      async throws -> T
    {
      try await self.context.perform {
        try operation(self.context._managedObjectContext.wrappedValue)
      }
    }

    @discardableResult
    public func withManagedObjectContext<T: Sendable>(
      perform operation: (NSManagedObjectContext) -> T
    )
      async -> T
    {
      await self.context.perform {
        operation(self.context._managedObjectContext.wrappedValue)
      }
    }
  }

  extension ManagedObjectContext {
    @_disfavoredOverload
    public func perform<T: Sendable>(operation: () -> T)
      async -> T
    {
      await withUnsafeContinuation { continuation in
        let result = LockIsolated(T?.none)
        self._managedObjectContext.wrappedValue.performAndWait {
          result.withValue {
            $0 = operation()
          }
        }
        continuation.resume(returning: result.value!)
      }
    }
    @_disfavoredOverload
    public func perform<T: Sendable>(operation: () throws -> T)
      async throws -> T
    {
      try await withUnsafeThrowingContinuation { continuation in
        let result = LockIsolated(Result<T, Error>?.none)
        self._managedObjectContext.wrappedValue.performAndWait {
          result.withValue {
            $0 = Result<T, Error> { try operation() }
          }
        }
        continuation.resume(with: result.value!)
      }
    }
  }

  extension ViewContext {
    public func perform<T: Sendable>(operation: @MainActor @Sendable () throws -> T)
      async rethrows -> T
    {
      try await MainActor.run(resultType: T.self, body: operation)
    }

    @MainActor
    public func perform<T>(operation: @MainActor () throws -> T) rethrows -> T {
      try operation()
    }
  }

  extension PersistentContainer {
    public struct FetchRequest {
      let persistentContainer: PersistentContainer

      init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
      }
    }
  }

  extension PersistentContainer {
    public var isolated: IsolatedManagedObjectContext {
      IsolatedManagedObjectContext(persistentContainer: self)
    }
    public struct IsolatedManagedObjectContext {
      let persistentContainer: PersistentContainer
      public var viewContext: ViewContext {
        ViewContext(self.persistentContainer.viewContext)
      }
      public func newChildViewContext() -> ViewContext {
        ViewContext(self.persistentContainer.newChildViewContext())
      }
      public func newBackgroundContext() -> AnyManagedObjectContext {
        AnyManagedObjectContext(self.persistentContainer.newBackgroundContext())
      }
    }
  }

  extension PersistentContainer.FetchRequest {
    public func callAsFunction<
      ManagedObject: NSManagedObject,
      Context: ManagedObjectContext
    >(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = [],
      context: Context
    ) -> AsyncThrowingStream<Results<ManagedObject, Context>, Error> {
      let fetchRequest = NSFetchRequest<ManagedObject>(
        entityName: String(describing: ManagedObject.self))
      fetchRequest.predicate = predicate
      fetchRequest.sortDescriptors = sortDescriptors
      if fetchRequest.sortDescriptors!.isEmpty {
        fetchRequest.sortDescriptors?.append(
          .init(key: "objectID", ascending: true)
        )
      }
      return stream(
        fetchRequest: fetchRequest,
        context: context
      )
    }

    public func callAsFunction<ManagedObject: NSManagedObject>(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = []
    ) -> AsyncThrowingStream<Results<ManagedObject, ViewContext>, Error> {
      let context = persistentContainer.isolated.viewContext
      let fetchRequest = NSFetchRequest<ManagedObject>(
        entityName: String(describing: ManagedObject.self))
      fetchRequest.predicate = predicate
      fetchRequest.sortDescriptors = sortDescriptors
      if fetchRequest.sortDescriptors!.isEmpty {
        fetchRequest.sortDescriptors?.append(
          .init(key: "objectID", ascending: true)
        )
      }
      return stream(
        fetchRequest: fetchRequest,
        context: context
      )
    }

    public func callAsFunction<
      SectionIdentifier: Hashable,
      ManagedObject: NSManagedObject,
      Context: ManagedObjectContext
    >(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = [],
      sectionIdentifier: KeyPath<ManagedObject, SectionIdentifier>,
      context: Context
    ) -> AsyncThrowingStream<
      SectionedResults<SectionIdentifier, ManagedObject, Context>, Error
    > {
      let fetchRequest = NSFetchRequest<ManagedObject>(
        entityName: String(describing: ManagedObject.self))
      fetchRequest.predicate = predicate
      fetchRequest.sortDescriptors = sortDescriptors

      if fetchRequest.sortDescriptors!.first?.keyPath != sectionIdentifier {
        fetchRequest.sortDescriptors?.insert(
          .init(keyPath: sectionIdentifier, ascending: true), at: 0
        )
      }

      return stream(
        fetchRequest: fetchRequest,
        sectionIdentifier: sectionIdentifier,
        context: context
      )
    }

    public func callAsFunction<
      SectionIdentifier: Hashable,
      ManagedObject: NSManagedObject
    >(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = [],
      sectionIdentifier: KeyPath<ManagedObject, SectionIdentifier>
    ) -> AsyncThrowingStream<
      SectionedResults<SectionIdentifier, ManagedObject, ViewContext>, Error
    > {
      let context = self.persistentContainer.isolated.viewContext
      let fetchRequest = NSFetchRequest<ManagedObject>(
        entityName: String(describing: ManagedObject.self))
      fetchRequest.predicate = predicate
      fetchRequest.sortDescriptors = sortDescriptors

      if fetchRequest.sortDescriptors!.first?.keyPath != sectionIdentifier {
        fetchRequest.sortDescriptors?.insert(
          .init(keyPath: sectionIdentifier, ascending: true), at: 0
        )
      }

      return stream(
        fetchRequest: fetchRequest,
        sectionIdentifier: sectionIdentifier,
        context: context
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

  extension PersistentContainer.FetchRequest {
    public struct SectionedResults<
      SectionIdentifier: Hashable & Sendable,
      ManagedObject: NSManagedObject,
      Context: ManagedObjectContext
    >:
      Sendable, Hashable
    {
      public struct Section: Hashable, Identifiable, Sendable {
        public let id: SectionIdentifier
        let fetchedObjects: Results<ManagedObject, Context>
      }

      let sections: [Section]

      init(sections: [Section] = []) {
        self.sections = sections
      }

      public static var empty: Self {
        .init()
      }
    }
  }

  extension PersistentContainer.FetchRequest {
    public struct Results<ManagedObject: NSManagedObject, Context: ManagedObjectContext>: Hashable,
      Sendable
    {
      let fetchedObjects: [_AnyFetched<ManagedObject, Context>]
      init(fetchedObjects: [_AnyFetched<ManagedObject, Context>] = []) {
        self.fetchedObjects = fetchedObjects
      }
      public static var empty: Self {
        .init()
      }
    }
  }

  extension PersistentContainer.FetchRequest.Results: RandomAccessCollection {
    public var startIndex: Int { fetchedObjects.startIndex }
    public var endIndex: Int { fetchedObjects.endIndex }

    public subscript(position: Int) -> _AnyFetched<ManagedObject, Context> {
      fetchedObjects[position]
    }

    public func index(after i: Int) -> Int {
      fetchedObjects.index(after: i)
    }

    public func index(before i: Int) -> Int {
      fetchedObjects.index(before: i)
    }
  }

  extension PersistentContainer.FetchRequest.SectionedResults: RandomAccessCollection {
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

  extension PersistentContainer.FetchRequest.SectionedResults.Section: RandomAccessCollection {
    public var startIndex: Int { fetchedObjects.startIndex }
    public var endIndex: Int { fetchedObjects.endIndex }

    public subscript(position: Int) -> _AnyFetched<ManagedObject, Context> {
      fetchedObjects[position]
    }

    public func index(after i: Int) -> Int {
      fetchedObjects.index(after: i)
    }

    public func index(before i: Int) -> Int {
      fetchedObjects.index(before: i)
    }
  }

  extension PersistentContainer.FetchRequest {
    func stream<ManagedObject: NSManagedObject, Context: ManagedObjectContext>(
      fetchRequest: NSFetchRequest<ManagedObject>,
      context: Context
    ) -> AsyncThrowingStream<Results<ManagedObject, Context>, Error> {
      AsyncThrowingStream<Results<ManagedObject, Context>, Error> { continuation in
        let fetchRequest = UncheckedSendable(fetchRequest.copy() as! NSFetchRequest<ManagedObject>)
        let currentValue = LockIsolated(Results<ManagedObject, Context>(fetchedObjects: []))
        @Sendable
        func fetchResults(updated: Set<NSManagedObjectID> = []) {
          context._managedObjectContext.wrappedValue.perform {
            do {
              try currentValue.withValue { currentValue in
                var tokens = [NSManagedObjectID: UUID]()
                for value in currentValue {
                  tokens[value.id] = value.token
                }
                tokens = tokens.filter { !updated.contains($0.key) }

                let results = try context._managedObjectContext.wrappedValue.fetch(
                  fetchRequest.wrappedValue)
                currentValue = .init(
                  fetchedObjects:
                    results.map {
                      _AnyFetched(
                        id: $0.objectID,
                        context: context,
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
          context: context._managedObjectContext.wrappedValue,
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

    func stream<
      SectionIdentifier: Hashable & Sendable,
      ManagedObject: NSManagedObject,
      Context: ManagedObjectContext
    >(
      fetchRequest: NSFetchRequest<ManagedObject>,
      sectionIdentifier: KeyPath<ManagedObject, SectionIdentifier>,
      context: Context
    ) -> AsyncThrowingStream<SectionedResults<SectionIdentifier, ManagedObject, Context>, Error> {
      AsyncThrowingStream<SectionedResults<SectionIdentifier, ManagedObject, Context>, Error> {
        continuation in
        let fetchRequest = UncheckedSendable(fetchRequest.copy() as! NSFetchRequest<ManagedObject>)
        let currentValue = LockIsolated(
          SectionedResults<SectionIdentifier, ManagedObject, Context>(sections: []))
        let sectionIdentifier = UncheckedSendable(sectionIdentifier)
        @Sendable
        func fetchResults(updated: Set<NSManagedObjectID> = []) {
          context._managedObjectContext.wrappedValue.perform {
            do {
              try currentValue.withValue { currentValue in
                var tokens = [NSManagedObjectID: UUID]()
                for section in currentValue.sections {
                  for value in section {
                    tokens[value.id] = value.token
                  }
                }
                tokens = tokens.filter { !updated.contains($0.key) }

                let results = try context._managedObjectContext.wrappedValue.fetch(
                  fetchRequest.wrappedValue)

                currentValue = SectionedResults<SectionIdentifier, ManagedObject, Context>(
                  sections:
                    results
                    .chunkedOn(keyPath: sectionIdentifier.wrappedValue)
                    .map {
                      SectionedResults<SectionIdentifier, ManagedObject, Context>.Section(
                        id: $0.0,
                        fetchedObjects: .init(
                          fetchedObjects:
                            $0.1.map {
                              _AnyFetched(
                                id: $0.objectID,
                                context: context,
                                token: tokens[$0.objectID, default: UUID()]
                              )
                            }
                        )
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
          context: context._managedObjectContext.wrappedValue,
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

    final class ManagedObjectUpdatesObserver: NSObject, Sendable {
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
#endif

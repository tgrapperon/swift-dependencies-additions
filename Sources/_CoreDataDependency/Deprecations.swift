#if canImport(CoreData)
  @preconcurrency import CoreData
  import PersistentContainerDependency
  import Dependencies

  extension PersistentContainer {
    @available(*, deprecated, message: "Use the variant that returns `MainFetched` values")
    @_disfavoredOverload
    @MainActor
    public func withViewContext<ManagedObject>(
      perform: @MainActor (NSManagedObjectContext) throws -> ManagedObject
    ) throws -> Fetched<ManagedObject> {
      let context = self.viewContext
      let object = try perform(self.viewContext)
      try context.obtainPermanentIDs(for: [object])
      return Fetched(
        id: object.objectID,
        context: context,
        viewContext: context
      )
    }

    @available(*, deprecated, message: "Use the variant that returns `MainFetched` values")
    @_disfavoredOverload
    @MainActor
    public func withNewChildViewContext<ManagedObject>(
      perform: @MainActor (NSManagedObjectContext) throws -> ManagedObject
    ) throws -> Fetched<ManagedObject> {
      let context = self.newChildViewContext()
      let object = try perform(context)
      try context.obtainPermanentIDs(for: [object])
      return Fetched(
        id: object.objectID,
        context: context,
        viewContext: context
      )
    }
  }

  extension PersistentContainer {
    @available(*, deprecated, message: "Use the variant ")
    public func insert<ManagedObject: NSManagedObject>(
      _ type: ManagedObject.Type,
      into context: NSManagedObjectContext?,
      configure: (ManagedObject) -> Void
    ) throws -> AnyFetched<ManagedObject> {
      let context = context ?? newBackgroundContext()
      let object = ManagedObject(context: context)
      try context.obtainPermanentIDs(for: [object])
      configure(object)
      return AnyFetched<ManagedObject>(
        id: object.objectID,
        context: AnyManagedObjectContext(context)
      )
    }
  }

  @available(*, deprecated, message: "Use `MainFetched` or `AnyFetched`")
  @dynamicMemberLookup
  public struct Fetched<ManagedObject: NSManagedObject>: Identifiable, Sendable, Hashable {
    public let id: NSManagedObjectID
    // This can be approximatively retrieved by users using `managedObjectContext`'s from dynamic
    // lookup.
    let context: NSManagedObjectContext
    let viewContext: NSManagedObjectContext
    var object: ManagedObject { self.context.object(with: self.id) as! ManagedObject }
    var token: UUID?
    init(
      id: NSManagedObjectID,
      context: NSManagedObjectContext,
      viewContext: NSManagedObjectContext,
      token: UUID? = nil
    ) {
      self.id = id
      self.context = context
      self.viewContext = viewContext
    }
    // This can go wrong very easily. We need a generic to make the distinction between main actor
    // context managed objects and bg ones.
    @MainActor
    public subscript<Value>(dynamicMember keyPath: KeyPath<ManagedObject, Value>) -> Value {
      (self.viewContext.object(with: self.id) as! ManagedObject)[keyPath: keyPath]
    }
  }

  @available(*, deprecated, message: "Use `MainFetched` or `AnyFetched`")
  extension Fetched {
    public var editor: Editor {
      get { .init(fetched: self) }
      set { self = newValue.fetched }
    }

    @dynamicMemberLookup
    public struct Editor {
      var fetched: Fetched

      var context: NSManagedObjectContext { fetched.viewContext }
      @MainActor
      public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ManagedObject, Value>) -> Value
      {
        get {
          (self.fetched.viewContext.object(with: self.fetched.id) as! ManagedObject)[
            keyPath: keyPath]
        }
        set {
          var object = (self.fetched.viewContext.object(with: self.fetched.id) as! ManagedObject)
          object[keyPath: keyPath] = newValue
          self.fetched.token = .init()
          self.fetched.viewContext.processPendingChanges()
        }
      }
    }
  }

  @available(*, deprecated)
  public enum ScheduledTaskType {
    case immediate
    case enqueued
  }

  @available(*, deprecated, message: "Use `MainFetched` or `AnyFetched`")
  extension Fetched {
    @discardableResult
    public func withManagedObject<T>(perform: (ManagedObject) -> T) -> T {
      var result: Swift.Result<T, Never>?
      self.context.performAndWait {
        result = .success(perform(self.object))
      }
      switch result! {
      case let .success(value):
        return value
      }
    }

    @discardableResult
    public func withManagedObject<T>(perform: (ManagedObject) throws -> T) throws -> T {
      var result: Swift.Result<T, Error>?
      self.context.performAndWait {
        result = .init(catching: { try perform(self.object) })
      }
      return try result!.get()
    }

    @discardableResult
    public func withManagedObject<T>(
      schedule: ScheduledTaskType = .immediate, perform: @escaping (ManagedObject) -> T
    ) async -> T {
      await withCheckedContinuation { continuation in
        switch schedule {
        case .immediate:
          continuation.resume(returning: self.withManagedObject(perform: perform))
        case .enqueued:
          withEscapedDependencies { dependencies in
            self.context.perform {
              dependencies.yield {
                continuation.resume(returning: perform(self.object))
              }
            }
          }
        }
      }
    }

    @discardableResult
    public func withManagedObject<T>(
      schedule: ScheduledTaskType = .immediate, perform: @escaping (ManagedObject) throws -> T
    ) async throws -> T {
      return try await withCheckedThrowingContinuation { continuation in
        switch schedule {
        case .immediate:
          continuation.resume(
            with: .init {
              try self.withManagedObject(perform: perform)
            })
        case .enqueued:
          withEscapedDependencies { dependencies in
            self.context.perform {
              dependencies.yield {
                continuation.resume(
                  with: .init {
                    try perform(self.object)
                  }
                )
              }
            }
          }
        }
      }
    }

    @discardableResult
    public func withManagedObjectContext<T>(perform: (NSManagedObjectContext) -> T) -> T {
      var result: Swift.Result<T, Never>?
      self.context.performAndWait {
        result = .success(perform(self.context))
      }
      switch result! {
      case let .success(value):
        return value
      }
    }

    @discardableResult
    public func withManagedObjectContext<T>(perform: (NSManagedObjectContext) throws -> T) throws
      -> T
    {
      var result: Swift.Result<T, Error>?
      self.context.performAndWait {
        result = .init(catching: { try perform(self.context) })
      }
      return try result!.get()
    }

    @discardableResult
    public func withManagedObjectContext<T>(
      schedule: ScheduledTaskType = .immediate, perform: @escaping (NSManagedObjectContext) -> T
    ) async -> T {
      return await withCheckedContinuation { continuation in
        switch schedule {
        case .immediate:
          continuation.resume(returning: self.withManagedObjectContext(perform: perform))
        case .enqueued:
          withEscapedDependencies { dependencies in
            self.context.perform {
              dependencies.yield {
                continuation.resume(returning: perform(self.context))
              }
            }
          }
        }
      }
    }

    @discardableResult
    public func withManagedObjectContext<T>(
      schedule: ScheduledTaskType = .immediate,
      perform: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
      return try await withCheckedThrowingContinuation { continuation in
        switch schedule {
        case .immediate:
          continuation.resume(
            with: .init {
              try self.withManagedObjectContext(perform: perform)
            })
        case .enqueued:
          withEscapedDependencies { dependencies in
            self.context.perform {
              dependencies.yield {
                continuation.resume(
                  with: .init {
                    try perform(self.context)
                  }
                )
              }
            }
          }
        }
      }
    }
  }

  extension PersistentContainer.FetchRequest {
    @available(*, deprecated)
    public struct SectionedResults<
      SectionIdentifier: Hashable & Sendable,
      ManagedObject: NSManagedObject
    >:
      Sendable, Hashable
    {
      public struct Section: Hashable, Identifiable, Sendable {
        public let id: SectionIdentifier
        let fetchedObjects: Results<ManagedObject>
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
  @available(*, deprecated, message: "Use variants that are returning isolated values")
  extension PersistentContainer.FetchRequest {
    @MainActor
    public func callAsFunction<ManagedObject: NSManagedObject>(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = [],
      context: NSManagedObjectContext? = nil
    ) -> AsyncThrowingStream<Results<ManagedObject>, Error> {
      let context = context ?? persistentContainer.viewContext
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
        context: context,
        viewContext: persistentContainer.viewContext
      )
    }

    @MainActor
    public func callAsFunction<SectionIdentifier: Hashable, ManagedObject: NSManagedObject>(
      _ type: ManagedObject.Type,
      predicate: NSPredicate? = nil,
      sortDescriptors: [NSSortDescriptor] = [],
      sectionIdentifier: KeyPath<ManagedObject, SectionIdentifier>,
      context: NSManagedObjectContext? = nil
    ) -> AsyncThrowingStream<
      SectionedResults<SectionIdentifier, ManagedObject>, Error
    > {
      let context = context ?? persistentContainer.viewContext
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
        context: context,
        viewContext: persistentContainer.viewContext
      )
    }
  }

  @available(*, deprecated)
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

  @available(*, deprecated)
  extension PersistentContainer.FetchRequest.SectionedResults.Section: RandomAccessCollection {
    public var startIndex: Int { fetchedObjects.startIndex }
    public var endIndex: Int { fetchedObjects.endIndex }

    public subscript(position: Int) -> Fetched<ManagedObject> {
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
    @available(*, deprecated)
    public struct Results<ManagedObject: NSManagedObject>: Hashable, Sendable {
      let fetchedObjects: [Fetched<ManagedObject>]
      init(fetchedObjects: [Fetched<ManagedObject>] = []) {
        self.fetchedObjects = fetchedObjects
      }

      public static var empty: Self {
        .init()
      }
    }
  }

  @available(*, deprecated)
  extension PersistentContainer.FetchRequest.Results: RandomAccessCollection {
    public var startIndex: Int { fetchedObjects.startIndex }
    public var endIndex: Int { fetchedObjects.endIndex }

    public subscript(position: Int) -> Fetched<ManagedObject> {
      fetchedObjects[position]
    }

    public func index(after i: Int) -> Int {
      fetchedObjects.index(after: i)
    }

    public func index(before i: Int) -> Int {
      fetchedObjects.index(before: i)
    }
  }

  @available(*, deprecated)
  extension PersistentContainer.FetchRequest {
    func stream<T: NSManagedObject>(
      fetchRequest: NSFetchRequest<T>,
      context: NSManagedObjectContext,
      viewContext: NSManagedObjectContext
    ) -> AsyncThrowingStream<Results<T>, Error> {
      AsyncThrowingStream<Results<T>, Error> { continuation in
        let context = UncheckedSendable(context)
        let fetchRequest = UncheckedSendable(fetchRequest.copy() as! NSFetchRequest<T>)
        let currentValue = LockIsolated(Results<T>(fetchedObjects: []))
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
                  fetchedObjects:
                    results.map {
                      Fetched(
                        id: $0.objectID,
                        context: context.wrappedValue,
                        viewContext: viewContext,
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
      context: NSManagedObjectContext,
      viewContext: NSManagedObjectContext
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
                        fetchedObjects: .init(
                          fetchedObjects:
                            $0.1.map {
                              Fetched(
                                id: $0.objectID,
                                context: context.wrappedValue,
                                viewContext: viewContext,
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
  }
#endif

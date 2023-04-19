#if canImport(CoreData)
  import CoreData
  @_exported import PersistentContainerDependency

  extension PersistentContainer {
    public var request: FetchRequest {
      .init(persistentContainer: self)
    }
  }

  extension PersistentContainer {
    @_disfavoredOverload
    @MainActor
    public func withViewContext<ManagedObject>(
      perform: @MainActor (NSManagedObjectContext) throws -> ManagedObject
    ) throws -> MainFetched<ManagedObject> {
      let context = self.viewContext
      let object = try perform(context)
      try context.obtainPermanentIDs(for: [object])
      return MainFetched(
        id: object.objectID,
        context: .init(context)
      )
    }

    @_disfavoredOverload
    @MainActor
    public func withNewChildViewContext<ManagedObject>(
      perform: @MainActor (NSManagedObjectContext) throws -> ManagedObject
    ) throws -> MainFetched<ManagedObject> {
      let context = self.newChildViewContext()
      let object = try perform(context)
      try context.obtainPermanentIDs(for: [object])
      return MainFetched(
        id: object.objectID,
        context: .init(context)
      )
    }

    @MainActor
    public func insert<ManagedObject: NSManagedObject>(
      _ type: ManagedObject.Type,
      configure: @MainActor (ManagedObject) -> Void = { _ in () }
    ) throws -> MainFetched<ManagedObject> {
      let context = self.viewContext
      let object = ManagedObject(context: context)
      try context.obtainPermanentIDs(for: [object])
      configure(object)
      return MainFetched<ManagedObject>(
        id: object.objectID,
        context: MainActorManagedObjectContext(context)
      )
    }
  }

#endif

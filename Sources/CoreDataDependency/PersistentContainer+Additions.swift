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
    perform: @MainActor @escaping (NSManagedObjectContext) throws -> ManagedObject
  ) throws -> Fetched<ManagedObject> {
    let context = self.viewContext
    let object = try perform(self.viewContext)
    try context.obtainPermanentIDs(for: [object])
    return Fetched(id: object.objectID, context: context, viewContext: context)
  }
}

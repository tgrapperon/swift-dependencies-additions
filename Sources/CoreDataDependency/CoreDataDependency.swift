import BundleInfo
import CoreData
import Dependencies
import LoggerDependency

extension DependencyValues {
   public var persistentContainer: PersistentContainer {
    get { self[PersistentContainer.self] }
    set { self[PersistentContainer.self] = newValue }
  }
}

extension PersistentContainer: DependencyKey {
  public static var liveValue: PersistentContainer {
    canonical()
  }

  public static var testValue: PersistentContainer {
    XCTFail(#"Unimplemented: @Dependency(\.persistentContainer)"#)
    return canonical(inMemory: true)
  }

  public static var previewValue: PersistentContainer {
    canonical(inMemory: true)
  }
}

extension PersistentContainer {
  public var fetchRequest: FetchRequest {
    .init()
  }
}

extension PersistentContainer {
  public static func canonical(inMemory: Bool = false) -> PersistentContainer {
    var name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    if Bundle.main.url(forResource: name, withExtension: "momd") == nil {
      name = Bundle.main.url(forResource: nil, withExtension: "momd")?
        .deletingPathExtension()
        .lastPathComponent
        ?? "Model"
    }

    let persistentContainer = NSPersistentContainer(name: name)
    guard !persistentContainer.persistentStoreDescriptions.isEmpty else {
      return .init(persistentContainer)
    }
    if inMemory {
      persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    persistentContainer.loadPersistentStores(completionHandler: { _, error in
      if let error {
        print("Failed to load PesistentStore: \(error)")
      }
    })
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    return .init(persistentContainer)
  }
}

public struct PersistentContainer: Sendable {
  public enum ScheduledTaskType {
    case immediate
    case scheduled
  }

  let _viewContext: @Sendable () -> UncheckedSendable<NSManagedObjectContext>
  let _newBackgroundContext: @Sendable () -> UncheckedSendable<NSManagedObjectContext>
  //  let lock = NSRecursiveLock()

  init(_ persistentContainer: NSPersistentContainer) {
    let persistentContainer = UncheckedSendable(persistentContainer)
    self._viewContext = { .init(persistentContainer.viewContext) }
    self._newBackgroundContext = { .init(persistentContainer.wrappedValue.newBackgroundContext()) }
  }

  @MainActor
  var viewContext: NSManagedObjectContext {
    self._viewContext().wrappedValue
  }

  func newBackgroundContext() -> NSManagedObjectContext {
    self._newBackgroundContext().wrappedValue
  }

  // TODO: Check if we can improve with inheritsActorContext
  @MainActor
  public func withViewContext<R: Sendable>(
    perform: @MainActor @escaping (NSManagedObjectContext) throws -> R
  ) rethrows -> R {
    try perform(self.viewContext)
  }

  public func withNewBackgroundContext<R: Sendable>(
    perform: @escaping (NSManagedObjectContext) throws -> R
  ) async throws -> R {
    try await withContext(self.newBackgroundContext(), perform: perform)
  }

  // Rethrows diagnostic doesn't work well, so we explicitly provide an overload for non-throwing
  // closures.
  public func withNewBackgroundContext<R: Sendable>(
    perform: @escaping (NSManagedObjectContext) -> R
  ) async -> R {
    try! await withContext(self.newBackgroundContext(), perform: perform)
  }
  
  func withContext<R: Sendable>(
    _ context: NSManagedObjectContext,
    perform: @escaping (NSManagedObjectContext) throws -> R
  ) async throws -> R {
    return try await withCheckedThrowingContinuation { continuation in
      context.performAndWait {
        continuation.resume(
          with: Result {
            try perform(context)
          }
        )
      }
    }
  }
  
  @MainActor
  public func with(
    operation: @escaping @MainActor (NSManagedObjectContext) throws -> Void
  ) rethrows -> Self {
    try withViewContext(perform: operation)
    return self
  }

  
  public func setUp(
    operation: @escaping (NSManagedObjectContext) throws -> Void,
    catch onFailure: @escaping (NSManagedObjectContext, Error) -> Void = { _, _ in () }
  ) -> Self {
    let context = self.newBackgroundContext()
    context.perform {
      do {
        try operation(context)
        if context.hasChanges {
          try context.save()
        }
      } catch {
        onFailure(context, error)
      }
    }
    return self
  }
  
}

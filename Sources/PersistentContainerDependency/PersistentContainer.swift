#if canImport(CoreData)
import CoreData
import Dependencies

extension DependencyValues {
  public var persistentContainer: PersistentContainer {
    get { self[PersistentContainer.self] }
    set { self[PersistentContainer.self] = newValue }
  }
}

extension PersistentContainer: DependencyKey {
  public static var liveValue: PersistentContainer {
    .default()
  }

  public static var testValue: PersistentContainer {
    let container = PersistentContainer.default(inMemory: true)
    return PersistentContainer(
      viewContext: unimplemented(
        #"@Dependency(\.persistentContainer.viewContext)"#,
        placeholder: container._viewContext
      ),
      newChildViewContext: unimplemented(
        #"@Dependency(\.persistentContainer.newChildViewContext)"#,
        placeholder: container._newChildViewContext
      ),
      newBackgroundContext: unimplemented(
        #"@Dependency(\.persistentContainer.newBackgroundContext)"#,
        placeholder: container._newBackgroundContext
      )
    )
  }

  public static var previewValue: PersistentContainer {
    .default(inMemory: true)
  }
}

extension PersistentContainer {
  public static func `default`(inMemory: Bool = false) -> PersistentContainer {
    var name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    if Bundle.main.url(forResource: name, withExtension: "momd") == nil {
      name =
        Bundle.main.url(forResource: nil, withExtension: "momd")?
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
  @_spi(Internals)
  public let _viewContext: @Sendable () -> NSManagedObjectContext
  private let _newChildViewContext: @Sendable () -> NSManagedObjectContext
  private let _newBackgroundContext: @Sendable () -> NSManagedObjectContext

  public init(_ persistentContainer: NSPersistentContainer) {
    let persistentContainer = UncheckedSendable(persistentContainer)
    self._viewContext = { persistentContainer.viewContext }
    self._newBackgroundContext = {
      persistentContainer.wrappedValue.newBackgroundContext()
    }
    self._newChildViewContext = {
      let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
      context.parent = persistentContainer.viewContext
      return context
    }
  }

  public init(
    viewContext: @escaping @Sendable () -> NSManagedObjectContext,
    newChildViewContext: @escaping @Sendable () -> NSManagedObjectContext,
    newBackgroundContext: @escaping @Sendable () -> NSManagedObjectContext
  ) {
    self._viewContext = { viewContext() }
    self._newChildViewContext = { newChildViewContext() }
    self._newBackgroundContext = { newBackgroundContext() }
  }

  public var viewContext: NSManagedObjectContext {
    self._viewContext()
  }

  public func newBackgroundContext() -> NSManagedObjectContext {
    self._newBackgroundContext()
  }

  public func newChildViewContext() -> NSManagedObjectContext {
    self._newChildViewContext()
  }
}

extension PersistentContainer {
  @MainActor
  public func withViewContext<R: Sendable>(
    perform: @MainActor (NSManagedObjectContext) throws -> R
  ) rethrows -> R {
    try perform(self.viewContext)
  }

  @MainActor
  public func withNewChildViewContext<R: Sendable>(
    perform: @MainActor (NSManagedObjectContext) throws -> R
  ) rethrows -> R {
    try perform(self.newChildViewContext())
  }

  public func withNewBackgroundContext<R: Sendable>(
    perform: (NSManagedObjectContext) throws -> R
  ) async throws -> R {
    try await self.withContext(self.newBackgroundContext(), perform: perform)
  }

  // Rethrow's diagnostic doesn't work well, so we explicitly provide an overload for non-throwing
  // closures.
  public func withNewBackgroundContext<R: Sendable>(
    perform: (NSManagedObjectContext) -> R
  ) async -> R {
    try! await self.withContext(self.newBackgroundContext(), perform: perform)
  }

  private func withContext<R: Sendable>(
    _ context: NSManagedObjectContext,
    perform: (NSManagedObjectContext) throws -> R
  ) async throws -> R {
    try await withCheckedThrowingContinuation { continuation in
      context.performAndWait {
        continuation.resume(
          with: Result {
            try perform(context)
          }
        )
      }
    }
  }
}

extension PersistentContainer {
  /// Performs an synchronous operation on the `MainActor` context and then returns itself.
  /// - Parameter operation: A operation to perform on the persistent container's `viewContext` that
  /// is provided as argument.
  ///
  /// This method can be useful to setup a persistent container for `SwiftUI` previews for example.
  /// If you need to perform business logic operations on the `viewContext`, you should preferably
  ///  use ``PersistentContainer/withViewContext(perform:)`` instead.
  ///
  /// - Returns: The ``PersistentContainer``
  @MainActor
  public func with(
    operation: @MainActor (NSManagedObjectContext) throws -> Void
  ) rethrows -> Self {
    try self.withViewContext(perform: operation)
    return self
  }

  /// Schedules an operation to be executed on a background context.
  ///
  /// This method can be useful to perform maintenance tasks at launch.
  ///
  /// This method returns immediately.
  /// - Parameters:
  ///   - operation: An operation to execute on the background context provided as argument.
  ///   - onFailureHandler: A function to handle errors thrown in `operation`.
  /// - Returns: The ``PersistentContainer`` value, with the operation scheduled on a background
  /// context.
  public func setUp(
    operation: @escaping (NSManagedObjectContext) throws -> Void,
    catch onFailureHandler: @escaping (NSManagedObjectContext, Error) -> Void = { _, _ in () }
  ) -> Self {
    let context = self.newBackgroundContext()

    withEscapedDependencies { continuation in
      context.perform {
        continuation.yield {
          do {
            try operation(context)
            if context.hasChanges {
              try context.save()
            }
          } catch {
            onFailureHandler(context, error)
          }
        }
      }
    }
    return self
  }
}
#endif

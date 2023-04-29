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
    /// Returns a ``PersistentContainer`` value corresponding to the first managed object model it
    /// finds in the `.main` bundle.
    public static func `default`(inMemory: Bool = false) -> PersistentContainer {
      PersistentContainer(inMemory: inMemory)
    }

    /// Creates a ``PersistentContainer`` value.
    ///
    /// - Parameters:
    ///   - name: The name of the CoreData model, without extension. If you specify `nil` (the
    ///   default), the library will use the first CoreData model it finds in the provided `Bundle`.
    ///   - bundle: The bundle where this model is stored.
    ///   - inMemory: A boolean flag that makes this ``PersistentContainer`` work in-memory only,
    ///   without writing to disk. You typically set this flag to `true` when testing.
    ///
    /// - Returns: A ``PersistentContainer`` value
    public init(
      name: String? = nil,
      bundle: Bundle = .main,
      inMemory: Bool = false
    ) {
      var name = name ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
      let managedObjectModel: NSManagedObjectModel
      if let url = bundle.url(forResource: name, withExtension: "momd"),
        let model = loadManagedObjectModel(url: url)
      {
        managedObjectModel = model
      } else if let url = bundle.url(forResource: nil, withExtension: "momd"),
        let model = loadManagedObjectModel(url: url)
      {
        name = url.deletingPathExtension().lastPathComponent
        managedObjectModel = model
      } else {
        fatalError(
          "Unable to find a suitable CoreData model named \"\(name)\" in the specified Bundle."
        )
      }

      let persistentContainer = NSPersistentContainer(
        name: name,
        managedObjectModel: managedObjectModel
      )

      guard !persistentContainer.persistentStoreDescriptions.isEmpty else {
        self = .init(persistentContainer)
        return
      }
      if inMemory {
        persistentContainer.persistentStoreDescriptions.first!.url = URL(
          fileURLWithPath: "/dev/null")
      }
      persistentContainer.loadPersistentStores(completionHandler: { _, error in
        if let error {
          print("Failed to load PesistentStore: \(error)")
        }
      })
      self = .init(persistentContainer)
    }
  }

  // Managed object models are cached, and loading the same model twice is ambiguous, so we keep a
  // trace of the models we loaded to return them again if possible. This is especially true when
  // testing.
  private let loadedModels = LockIsolated([URL: UncheckedSendable<NSManagedObjectModel?>]())
  private func loadManagedObjectModel(url: URL) -> NSManagedObjectModel? {
    if let model = loadedModels.value[url]?.wrappedValue {
      return model
    }
    let model = UncheckedSendable(NSManagedObjectModel(contentsOf: url))
    loadedModels.withValue {
      $0[url] = model
    }
    return model.wrappedValue
  }

  public struct PersistentContainer: Sendable {
    @_spi(Internals)
    public let _viewContext: @Sendable () -> NSManagedObjectContext
    private let _newChildViewContext: @Sendable () -> NSManagedObjectContext
    private let _newBackgroundContext: @Sendable () -> NSManagedObjectContext

    /// Creates a ``PersistentContainer`` value from a `NSPersistentContainer` instance
    ///
    /// - Parameters:
    ///   - persistentContainer: A `NSPersistentContainer` instance
    ///   - inMemory: A boolean flag that makes this ``PersistentContainer`` work in-memory only,
    ///   without writing to disk. You typically set this flag to `true` when testing.
    public init(
      _ persistentContainer: NSPersistentContainer,
      inMemory: Bool = false
    ) {
      if inMemory {
        persistentContainer.persistentStoreDescriptions.first!.url = URL(
          fileURLWithPath: "/dev/null")
      }
      let persistentContainer = UncheckedSendable(persistentContainer)
      let isViewContextConfigured = LockIsolated(false)

      let viewContext = { @Sendable in
        let context = persistentContainer.viewContext
        isViewContextConfigured.withValue { isConfigured in
          if !isConfigured {
            context.automaticallyMergesChangesFromParent = true
            isConfigured = true
          }
        }
        return context
      }

      self._viewContext = viewContext
      self._newBackgroundContext = {
        persistentContainer.wrappedValue.newBackgroundContext()
      }
      self._newChildViewContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext()
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

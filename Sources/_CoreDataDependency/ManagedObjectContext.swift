import CoreData
import Dependencies

public protocol ManagedObjectContext: Hashable & Sendable {
  @_spi(Internals) var _managedObjectContext: UncheckedSendable<NSManagedObjectContext> { get }
}

public struct MainActorManagedObjectContext: ManagedObjectContext {
  @_spi(Internals) public var _managedObjectContext: UncheckedSendable<NSManagedObjectContext>
  @_spi(Internals) public init(_ managedObjectContext: NSManagedObjectContext) {
    assert(managedObjectContext.concurrencyType == .mainQueueConcurrencyType)
    self._managedObjectContext = .init(wrappedValue: managedObjectContext)
  }
}

public struct AnyManagedObjectContext: ManagedObjectContext {
  @_spi(Internals) public var _managedObjectContext: UncheckedSendable<NSManagedObjectContext>
  @_spi(Internals) public init(_ managedObjectContext: NSManagedObjectContext) {
    self._managedObjectContext = .init(wrappedValue: managedObjectContext)
  }
}

extension ManagedObjectContext {
  public static func managedObjectContext(_ managedObjectContext: NSManagedObjectContext)
    -> any ManagedObjectContext
  {
    if managedObjectContext.concurrencyType == .mainQueueConcurrencyType {
      return MainActorManagedObjectContext(managedObjectContext)
    }
    return AnyManagedObjectContext(managedObjectContext)
  }
}

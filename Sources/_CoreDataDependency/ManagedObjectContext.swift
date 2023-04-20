import CoreData
import Dependencies

public final class ViewContext: AnyManagedObjectContext {
  override init(_ managedObjectContext: NSManagedObjectContext) {
    assert(managedObjectContext.concurrencyType == .mainQueueConcurrencyType)
    super.init(managedObjectContext)
  }
}

public class AnyManagedObjectContext: @unchecked Sendable, Hashable {
  let _managedObjectContext: UncheckedSendable<NSManagedObjectContext>
  init(_ managedObjectContext: NSManagedObjectContext) {
    self._managedObjectContext = .init(wrappedValue: managedObjectContext)
  }

  public static func == (lhs: AnyManagedObjectContext, rhs: AnyManagedObjectContext) -> Bool {
    lhs._managedObjectContext == rhs._managedObjectContext
  }
  public func hash(into hasher: inout Hasher) {
    _managedObjectContext.hash(into: &hasher)
  }
}

extension AnyManagedObjectContext {
  public static func managedObjectContext(_ managedObjectContext: NSManagedObjectContext)
    -> AnyManagedObjectContext
  {
    if managedObjectContext.concurrencyType == .mainQueueConcurrencyType {
      return ViewContext(managedObjectContext)
    }
    return AnyManagedObjectContext(managedObjectContext)
  }
}

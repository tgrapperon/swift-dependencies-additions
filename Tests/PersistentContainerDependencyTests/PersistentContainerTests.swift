#if canImport(CoreData)
  import Dependencies
  import PersistentContainerDependency
  import XCTest
  import CoreData

  final class PersistentContainerTests: XCTestCase {
    @Dependency(\.persistentContainer) var persistentContainer

    static let model: NSManagedObjectModel = {
      let url = Bundle.module
        .url(forResource: "Model", withExtension: "momd")
      return NSManagedObjectModel(contentsOf: url!)!
    }()

    var newPersistentContainer: NSPersistentContainer {
      .init(name: "Model", managedObjectModel: Self.model)
    }

    func testPersistentContainerIsGeneratingViewContext() {
      withDependencies {
        $0.persistentContainer = .init(self.newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.viewContext
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
      }
    }
    func testPersistentContainerIsGeneratingNewViewContext() {
      withDependencies {
        $0.persistentContainer = .init(self.newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.newChildViewContext()
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
      }
    }
    func testPersistentContainerIsGeneratingNewBackgroundContext() {
      withDependencies {
        $0.persistentContainer = .init(self.newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.newBackgroundContext()
        XCTAssertEqual(viewContext.concurrencyType, .privateQueueConcurrencyType)
      }
    }
  }
#endif

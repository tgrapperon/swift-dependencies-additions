#if canImport(CoreData)
  import Dependencies
  import PersistentContainerDependency
  import XCTest
  import CoreData

  final class PersistentContainerTests: XCTestCase {
    @Dependency(\.persistentContainer) var persistentContainer

    static let model: NSManagedObjectModel? = {
      let url = Bundle.module
        .url(forResource: "Model", withExtension: "momd")
      return url.flatMap(NSManagedObjectModel.init(contentsOf:))
    }()

    var newPersistentContainer: NSPersistentContainer? {
      Self.model.map { .init(name: "Model", managedObjectModel: $0) }
    }

    func testPersistentContainerIsGeneratingViewContext() {
      guard let newPersistentContainer else {
        print(
          "Warning, testPersistentContainerIsGeneratingViewContext is not executed in this context"
        )
        return
      }
      withDependencies {
        $0.persistentContainer = .init(newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.viewContext
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
      }
    }
    func testPersistentContainerIsGeneratingNewViewContext() {
      guard let newPersistentContainer else {
        print(
          "Warning, testPersistentContainerIsGeneratingNewViewContext is not executed in this context"
        )
        return
      }
      withDependencies {
        $0.persistentContainer = .init(newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.newChildViewContext()
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
      }
    }
    func testPersistentContainerIsGeneratingNewBackgroundContext() {
      guard let newPersistentContainer else {
        print(
          "Warning, testPersistentContainerIsGeneratingNewBackgroundContext is not executed in this context"
        )
        return
      }
      withDependencies {
        $0.persistentContainer = .init(newPersistentContainer, inMemory: true)
      } operation: {
        let viewContext = self.persistentContainer.newBackgroundContext()
        XCTAssertEqual(viewContext.concurrencyType, .privateQueueConcurrencyType)
      }
    }
  }
#endif

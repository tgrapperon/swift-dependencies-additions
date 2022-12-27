import CoreDataDependency
import Dependencies
import SwiftUI

@MainActor
final class CoreDataStudy: ObservableObject {
  @Dependency(\.persistentContainer) var persistentContainer
  @Dependency(\.persistentContainer.fetchRequest) var fetchRequest

  @Published var persons: CoreDataDependency.FetchRequest.Results<Person> = .init()
  var observation: Task<Void, Never>?
  init() {
    self.observation = Task { [weak self] in
      guard let self else { return }
      do {
        for try await persons in self.fetchRequest(
          of: Person.self,
          sortDescriptors: [
            NSSortDescriptor(key: "age", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
          ]
        ) {
          withAnimation {
            self.persons = persons
          }
        }
      } catch {}
    }
  }
  
  func userDidTapAddNewPersonButton() {
    persistentContainer.withViewContext { context in
      let person = Person(context: context)
      person.name = "Blob Sr"
      person.age = Int64.random(in: 55...100)
      person.identifier = .init()
      try? context.save()
    }
  }

  deinit {
    observation?.cancel()
  }
}

struct CoreDataStudyView: View {
  @ObservedObject var model: CoreDataStudy
  var body: some View {
    List {
      Section {
        Button {
          model.userDidTapAddNewPersonButton()
        } label: {
          Text("Add new person")
        }
      }

      ForEach(model.persons) { person in
        person.withValue { person in
          LabeledContent(person.name ?? "?", value: person.age.formatted())
        }
      }
    }
  }
}

struct CoreDataStudyView_Previews: PreviewProvider {
  static var previews: some View {
    CoreDataStudyView(
      model:
        DependencyValues.withValues {
          let container = PersistentContainer.canonical(inMemory: true)
          $0.persistentContainer = container
          
          container.withViewContext { context in
            do {
              let person = Person(context: context)
              person.name = "Blob"
              person.identifier = UUID()
              person.age = 34
            }
            
            do {
              let person = Person(context: context)
              person.name = "Blob Jr."
              person.identifier = UUID()
              person.age = 2
            }
            
          }
        } operation: {
          .init()
        }
    )
  }
}

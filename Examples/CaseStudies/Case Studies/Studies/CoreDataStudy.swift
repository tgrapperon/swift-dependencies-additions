import CoreDataDependency
import Dependencies
import SwiftUI

@MainActor
final class CoreDataStudy: ObservableObject {
  @Dependency(\.persistentContainer) var persistentContainer
  @Dependency(\.persistentContainer.fetchRequest) var fetchRequest
  
  @Dependency(\.logger["CoreDataStudy"]) var logger
  
  @Published var persons: CoreDataDependency.FetchRequest.Results<Person> = .init()
  var observation: Task<Void, Never>?
  init() {
    self.observation = Task { [weak self] in
      guard let self else { return }
      do {
        for try await persons in self.fetchRequest(
          of: Person.self,
          sortDescriptors: [
            NSSortDescriptor(keyPath: \Person.age, ascending: true),
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
      person.age = Int64.random(in: 55 ... 100)
      person.identifier = .init()
      try? context.save()
    }
  }
  
  func userDidSwipeDeletePerson(person: FetchedResult<Person>) {
    do {
      try person.withValue { person in
        let context = person.managedObjectContext
        context?.delete(person)
        try context?.save()
      }
    } catch {
      logger.error("Failed to delete person: \(error)")
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
      Section {
        ForEach(model.persons) { person in
          person.withValue { person in
            VStack(alignment: .leading) {
              LabeledContent(person.name ?? "?", value: person.age.formatted())
              Text(person.identifier!.uuidString)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
          .swipeActions {
            Button(role: .destructive) {
              model.userDidSwipeDeletePerson(person: person)
            } label: {
              Label("Delete", systemImage: "trash")
            }

          }
        }
      } header: {
        Text("^[\(model.persons.count) \("person")](inflect: true)")
      }
    }.headerProminence(.increased)
  }
}

struct CoreDataStudyView_Previews: PreviewProvider {
  static var previews: some View {
    CoreDataStudyView(
      model:
        DependencyValues.withValues { values in
          values.persistentContainer = PersistentContainer
            .canonical(inMemory: true)
            .with { context in
              @Dependency(\.uuid) var uuid

              do {
                let person = Person(context: context)
                person.name = "Blob"
                person.identifier = uuid()
                person.age = 34
              }

              do {
                let person = Person(context: context)
                person.name = "Blob Jr."
                person.identifier = uuid()
                person.age = 2
              }
            }
        } operation: {
          CoreDataStudy()
        }
    )
  }
}

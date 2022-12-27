import CoreDataDependency
import Dependencies
import SwiftUI

@MainActor
final class CoreDataStudy: ObservableObject {
  @Dependency(\.persistentContainer) var persistentContainer
  @Dependency(\.persistentContainer.fetchRequest) var fetchRequest
  
  @Dependency(\.logger["CoreDataStudy"]) var logger
  
  @Published var composers: CoreDataDependency.FetchRequest.Results<Composer> = .init()
  var observation: Task<Void, Never>?
  init() {
    self.observation = Task { [weak self] in
      guard let self else { return }
      do {
        for try await composers in self.fetchRequest(
          of: Composer.self,
          sortDescriptors: [
            NSSortDescriptor(keyPath: \Composer.songsCount, ascending: false),
            NSSortDescriptor(keyPath: \Composer.name, ascending: true),
          ]
        ) {
          withAnimation {
            self.composers = composers
          }
        }
      } catch {}
    }
  }

//  func userDidTapAddNewPersonButton() {
//    persistentContainer.withViewContext { context in
//      let composer = Composer(context: context)
//      composer.identifier = .init()
//      composer.name = "Blob Sr"
//      try? context.save()
//    }
//  }
  
  func userDidSwipeDeletePerson(composer: Composer.Value) {
    do {
      try composer.withManagedObject { composer in
        let context = composer.managedObjectContext
        context?.delete(composer)
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
          Text("Add new Composer")
        }
      }
      Section {
        ForEach(model.composers) { composer in

          composer.withManagedObject { composer in
            VStack(alignment: .leading) {
              
              LabeledContent(composer.name ?? "?", value: composer.songsCount.formatted())
              Text(composer.identifier!.uuidString)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
//          .swipeActions {
//            Button(role: .destructive) {
//              model.userDidSwipeDeletePerson(composer: composer)
//            } label: {
//              Label("Delete", systemImage: "trash")
//            }
//
//          }
        }
      } header: {
        Text("^[\(model.composers.count) \("composer")](inflect: true)")
      }
    }.headerProminence(.increased)
  }
}


fileprivate final class SongsModel: ObservableObject {
  
  
}
struct SongsView: View {
  
  
  var body: some View {
    Color.red
  }
}

struct CoreDataStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CoreDataStudyView(
        model:
          DependencyValues.withValues { values in
            values.persistentContainer = PersistentContainer
              .canonical(inMemory: true)
              .withInitialData()
          } operation: {
            CoreDataStudy()
          }
      )
    }
  }
}

extension PersistentContainer {
  @MainActor
  func withInitialData() -> Self {
    self.with { context in
      @Dependency(\.uuid) var uuid

      func song(_ name: String, year: Int64) -> Song {
        let song = Song(context: context)
        song.identifier = uuid()
        song.name = name
        song.year = year
        return song
      }
      
      func composer(name: String) -> Composer {
        let composer = Composer(context: context)
        composer.identifier = uuid()
        composer.name = name
        return composer
      }
      
      let yesterday = song("Yesterday", year: 1965)
      let allMyLoving = song("All My Loving", year: 1965)
      let aDayInTheLife = song("A Day In The Life", year: 1967)
      let help = song("Help!", year: 1965)
      let ticketToRide = song("Ticket To Ride", year: 1965)
      let something = song("Something", year: 1969)
      let whileMyGuitar = song("While My Guitar Gently Weeps", year: 1968)
      let octopussGarden = song("Octopuss Garden", year: 1969)
      let blackbird = song("Blackbird", year: 1968)


      let paul = composer(name: "Paul McCartney")
      let john = composer(name: "John Lennon")
      let george = composer(name: "George Harrison")
      let ringo = composer(name: "Ringo Starr")

      paul.addToSongs(yesterday)
      paul.addToSongs(allMyLoving)
      paul.addToSongs(aDayInTheLife)
      paul.addToSongs(blackbird)
      
      john.addToSongs(aDayInTheLife)
      john.addToSongs(help)
      john.addToSongs(ticketToRide)

      george.addToSongs(something)
      george.addToSongs(whileMyGuitar)
      
      ringo.addToSongs(octopussGarden)
      
      // We need to save so the derived `songsCount` relation is updated
      try! context.save()
    }
  }
}

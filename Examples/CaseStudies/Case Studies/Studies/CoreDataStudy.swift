import CoreDataDependency
import Dependencies
import SwiftUI

@MainActor
final class CoreDataStudy: ObservableObject {
  @Dependency(\.persistentContainer) var persistentContainer

  @Dependency(\.logger["CoreDataStudy"]) var logger

  @Published var composers: Composer.FetchedResults = .empty
  @Published var songsByYear: Song.SectionedFetchedResults<Int64> = .empty

  @Published var isLoadingComposers: Bool = false
  @Published var isLoadingSongs: Bool = false

  var tasks = Set<Task<Void, Never>>()
  init() {
    // Observe composers
    tasks.insert(
      Task { [weak self] in
        guard let self else { return }
        do {
          self.isLoadingComposers = true
          for try await composers in self.persistentContainer.request(
            Composer.self,
            sortDescriptors: [
              NSSortDescriptor(keyPath: \Composer.songsCount, ascending: false),
              NSSortDescriptor(keyPath: \Composer.name, ascending: true),
            ]
          ) {
            self.isLoadingComposers = false
            withAnimation {
              self.composers = composers
            }
          }
        } catch {}
      }
    )

    // Observe songs by year
    tasks.insert(
      Task { [weak self] in
        guard let self else { return }
        do {
          self.isLoadingSongs = true
          for try await sectionedSongs in self.persistentContainer.request(
            Song.self,
            sortDescriptors: [
              NSSortDescriptor(keyPath: \Song.year, ascending: true),
              NSSortDescriptor(keyPath: \Song.name, ascending: true),
            ],
            sectionIdentifier: \.year
          ) {
            self.isLoadingSongs = false
            withAnimation {
              self.songsByYear = sectionedSongs
            }
          }
        } catch {}
      }
    )
  }

  func userDidSwipeDeleteSongRow(song: Fetched<Song>) {
    do {
      try song.withManagedObject { song in
        let context = song.managedObjectContext
        context?.delete(song)
        try context?.save()
      }
    } catch {
      logger.error("Failed to delete song: \(error)")
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

  deinit {
    for task in tasks {
      task.cancel()
    }
  }
}

struct CoreDataStudyView: View {
  @ObservedObject var model: CoreDataStudy
  var body: some View {
    List {
      Section {
        //        Button {
        //          model.userDidTapAddNewPersonButton()
        //        } label: {
        //          Text("Add new Composer")
        //        }
      }
      Section {
        ForEach(model.composers) { composer in
          VStack(alignment: .leading) {
            LabeledContent(composer.name ?? "") {
              Text("^[\(composer.songsCount) \("song")](inflect: true)")
            }
          }
        }
      } header: {
        if model.isLoadingComposers {
          ProgressView()
        } else {
          Text("^[\(model.composers.count) \("composer")](inflect: true)")
        }
      }
      
      ForEach(model.songsByYear) { songsByYear in
        Section {

          ForEach(songsByYear) { song in
            VStack(alignment: .leading) {
              Text(song.name ?? "")
              Text(song.composersString)
                .foregroundStyle(.secondary)
                .font(.callout)
            }
            .swipeActions {
              Button(role: .destructive) {
                model.userDidSwipeDeleteSongRow(song: song)
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }
        } header: {
          Text("^[\(songsByYear.count) \("song")](inflect: true) from \(songsByYear.id.formatted(.number.grouping(.never)))")
        }
      }

    }.headerProminence(.increased)
      .navigationTitle("Core Data Study")
  }
}

private final class SongsModel: ObservableObject {}

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
        DependencyValues.withValue(
          \.persistentContainer, .canonical(inMemory: true).withInitialData()
        ) {
          CoreDataStudy()
        }
      )
    }
  }
}

extension PersistentContainer {
  @MainActor
  func withInitialData() -> Self {
    with { context in
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

extension Song {
  var composersString: String {
    (composers as! Set<Composer>)
      .map(\.name!)
      .sorted()
      .formatted(.list(type: .and))
  }
}

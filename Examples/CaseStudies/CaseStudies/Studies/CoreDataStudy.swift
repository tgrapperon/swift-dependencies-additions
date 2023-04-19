import _CoreDataDependency
import _SwiftUIDependency
import Dependencies
import SwiftUI
import SwiftUINavigation
@MainActor
final class CoreDataStudy: ObservableObject {
  enum Destination {
    case addSong(AddSongModel)
  }

  @Dependency(\.persistentContainer) var persistentContainer
  @Dependency(\.logger["CoreDataStudy"]) var logger
  @Dependency(\.uuid) var uuid

  @Published var composers: Composer.FetchedResults = .empty
  @Published var songsByYear: Song.SectionedFetchedResults<Int64> = .empty

  @Published var isLoadingComposers: Bool = false
  @Published var isLoadingSongs: Bool = false

  @Published var destination: Destination?

  var tasks = Set<Task<Void, Never>>()
  init(destination: Destination? = nil) {
    self.destination = destination
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
            // MainActor.run fixes a glitch where the UI doesn't update if the
            // changes are wrapped in a `withAnimation` block.
            await MainActor.run {
              withAnimation {
                self.isLoadingComposers = false
                self.composers = composers
              }
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
            // MainActor.run fixes a glitch where the UI doesn't update if the
            // changes are wrapped in a `withAnimation` block.
            await MainActor.run {
              withAnimation {
                self.isLoadingSongs = false
                self.songsByYear = sectionedSongs
              }
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

  func userDidTapAddNewSongButton() {
    do {
      destination = try withDependencies(from: self) {
        // We create a temporary `ViewContext` so:
        // - We can drive the API with it
        // - We can simply throw it away if the user doesn't effectively
        // save the new song.
        Destination.addSong(
          .init(
            song: try persistentContainer.withNewChildViewContext { context in
              let song = Song(context: context)
              song.identifier = self.uuid()
              song.name = "Let It Be"
              song.year = 1970
              return song
            }
          )
        )
      }
    } catch {
      logger.error("Failed to insert a new song: \(error)")
    }
  }

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
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          model.userDidTapAddNewSongButton()
        } label: {
          Label("Add a new song", systemImage: "plus")
        }
      }
    }
    .sheet(
      unwrapping: $model.destination,
      case: /CoreDataStudy.Destination.addSong
    ) { $model in
      NavigationStack {
        AddSongView(model: model)
      }
    }
    .headerProminence(.increased)
    .navigationTitle("Core Data Study")
  }
}

@MainActor
final class AddSongModel: ObservableObject {
  // A logger dependency that we use if saving fails
  @Dependency(\.logger["CoreDataStudy"]) var logger

  // In this example, we could use directly:
  // @Dependency.Environment(\.dismiss) var dismiss
  // but it is probably safer to namespace this dependency with an
  // `Hashable` identifier. We use here the static `id` property on
  // `ObservableObject` that ties this dependency to this model. We
  // could have used a `String` or any kind of value, but `Self.id`
  // locks the dependency's from the model with the environment
  // from its view.
  // We need to use the same identifier on the view's side when calling:
  // .observeEnvironmentAsDependency(\.dismiss, id: AddSongModel)
  @Dependency.Environment(\.dismiss, id: AddSongModel.self) var dismiss

  @Published var song: Fetched<Song>

  init(song: Fetched<Song>) {
    self.song = song
  }

  func doneButtonTapped() {
    saveSong()
    dismiss?()
  }

  func cancelButtonTapped() {
    dismiss?()
  }

  func saveSong() {
    do {
      try song.withManagedObjectContext {
        try $0.save()
      }
    } catch {
      logger.error("Failed to save")
    }
  }
}

struct AddSongView: View {
  @ObservedObject var model: AddSongModel

  var body: some View {
    Form {
      TextField("Name", text: $model.song.editor.name.emptyIfNil())
      Stepper(value: $model.song.editor.year, in: 1960 ... 1970) {
        LabeledContent("Year", value: "\(model.song.year)")
      }
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Done") {
          self.model.doneButtonTapped()
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          self.model.cancelButtonTapped()
        }
      }
    }
    .navigationTitle("Add Song")
    .observeEnvironmentAsDependency(\.dismiss, id: AddSongModel.self)
  }
}

struct CoreDataStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CoreDataStudyView(
        model:
        withDependencies {
          $0.persistentContainer = .default(inMemory: true).withInitialData()
        } operation: {
          CoreDataStudy()
        }
      )
    }

    // TODO: Having two previews creates navigation glitches.
//    NavigationStack {
//      AddSongView(
//        model:
//        withDependencies {
//          $0.persistentContainer = .canonical(inMemory: true).withInitialData()
//          $0.uuid = .incrementing
//        } operation: {
//          @Dependency(\.persistentContainer) var persistentContainer
//          @Dependency(\.uuid) var uuid
//
//          return AddSongModel(song: try! persistentContainer.insert(Song.self) {
//            $0.identifier = uuid()
//            $0.year = 1970
//            $0.name = "Let it be"
//          })
//        }
//      )
//    }
  }
}

public extension Binding {
  func nilIfEmpty() -> Binding<Value?> where Value: RangeReplaceableCollection {
    Binding<Value?> {
      self.wrappedValue.isEmpty ? nil : self.wrappedValue
    } set: { newValue, _ in
      self.transaction(transaction).wrappedValue = newValue ?? .init()
    }
  }

  func emptyIfNil<T>() -> Binding<T> where Value == T?, T: RangeReplaceableCollection {
    Binding<T> {
      self.wrappedValue ?? .init()
    } set: { newValue, _ in
      self.transaction(transaction).wrappedValue = newValue.isEmpty ? .none : newValue
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

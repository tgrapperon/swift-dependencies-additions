import Dependencies
import SwiftUI
import _SwiftUIDependency

@MainActor
final class SwiftUIEnvironmentStudy: ObservableObject {
  // This is the value itself, in the form of an `Optional<ColorScheme>`
  @Dependency(\.environment.colorScheme) var colorScheme
  
  // This is an `AsyncStream<ColorScheme>` of succesive values
  @Dependency(\.environment.streams.colorScheme) var colorSchemes

  var description: String {
    switch colorScheme {
    case .light:
      return "light"
    case .dark:
      return "dark"
    case .none:
      return "nil"
    case .some:
      return "I have no memories of this place"
    }
  }
  
  var observation: Task<Void, Never>?
  init() {
    self.observation = Task { [weak self] in
      guard let self else { return }
      for await _ in self.colorSchemes {
        self.objectWillChange.send()
      }
    }
  }
  
  deinit {
    self.observation?.cancel()
  }
}

struct SwiftUIEnvironmentStudyView: View {
  @ObservedObject var model: SwiftUIEnvironmentStudy
  @State var preferredColorScheme: ColorScheme = .light

  var body: some View {
    List {
      Section {
        LabeledContent("ColorScheme from Model", value: model.description)
          .observeEnvironmentAsDependency(\.colorScheme)
        LabeledContent("ColorScheme from View", value: String(describing: preferredColorScheme))
      }
      Button {
        if preferredColorScheme == .light {
          preferredColorScheme = .dark
        } else {
          preferredColorScheme = .light
        }
      } label: {
        Text("Toggle color scheme")
      }
    }
    .preferredColorScheme(preferredColorScheme)
    .navigationTitle("SwiftUI Environment")
  }
}

struct SwiftUIEnvironmentStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SwiftUIEnvironmentStudyView(model: .init())
    }
  }
}

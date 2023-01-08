import Dependencies
import SwiftUI
import _SwiftUIDependency
import LoggerDependency
import DependenciesAdditionsBasics

@MainActor
final class SwiftUIEnvironmentStudy: ObservableObject {
  @Dependency.Environment(\.colorScheme) var swiftUIColorScheme
  @Published var modelColorScheme: ColorScheme?
  @Dependency(\.logger["SwiftUIEnvironmentStudy"]) var logger
  var cancellables = Set<AnyCancellableTask>()
  init() {
    Task { [weak self] in
      guard let self else { return }
      for await colorScheme in self.$swiftUIColorScheme {
        self.modelColorScheme = colorScheme
        logger.info("User did select \(colorScheme.localizedDescription, privacy: .public)")
      }
    }.store(in: &cancellables)
  }
}

struct SwiftUIEnvironmentStudyView: View {
  @ObservedObject var model: SwiftUIEnvironmentStudy
  @State var preferredColorScheme: ColorScheme = .light
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    List {
      Section {
        LabeledContent("ColorScheme from Model", value: model.modelColorScheme.localizedDescription)
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

extension Optional where Wrapped == ColorScheme {
  var localizedDescription: String {
    switch self {
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
}

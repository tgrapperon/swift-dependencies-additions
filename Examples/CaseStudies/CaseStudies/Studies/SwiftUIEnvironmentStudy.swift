import Dependencies
import SwiftUI
import _SwiftUIDependency
import LoggerDependency

@MainActor
final class SwiftUIEnvironmentStudy: ObservableObject {
  @Dependency.Environment(\.colorScheme) var colorScheme
  @Dependency(\.logger["SwiftUIEnvironmentStudy"]) var logger
  var observation: Task<Void, Never>?
  init() {
    self.observation = Task { [weak self] in
      guard let self else { return }
      for await colorScheme in self.$colorScheme.dropFirst() {
        logger.info("User did select \(colorScheme.localizedDescription, privacy: .public)")
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
  // By installing this property wrapper in a `View`, we automatically
  // observe `@Environment(\.colorScheme).
  @Dependency.Environment(\.colorScheme) var colorScheme

  var body: some View {
    List {
      Section {
        LabeledContent("ColorScheme from Model", value: model.colorScheme.localizedDescription)
        LabeledContent("ColorScheme from View", value: String(describing: preferredColorScheme))
        LabeledContent("ColorScheme from wrapper", value: colorScheme.localizedDescription)

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

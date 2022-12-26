import SwiftUI
import SwiftUINavigation

class StudiesModel: ObservableObject {
  enum Destination {
    case loggerStudy(LoggerStudy)
  }
  @Published var destination: Destination?

  func userDidTapNavigateToLoggerStudyButton() {
    self.destination = .loggerStudy(
      .init(customerName: "Blob")
    )
  }
}

struct ContentView: View {
  @ObservedObject var model: StudiesModel
  
  var body: some View {
    NavigationStack {
      List {
        Button {
          self.model.userDidTapNavigateToLoggerStudyButton()
        } label: {
          Label("Logger Study", systemImage: "list.dash")
        }

      }
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.loggerStudy
      ) { $model in
        LoggerStudyView(model: model)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(model: .init())
  }
}

import SwiftUI
import SwiftUINavigation

@MainActor
class StudiesModel: ObservableObject {
  enum Destination {
    case notificationStudy(NotificationStudy)
    case loggerStudy(LoggerStudy)
  }
  @Published var destination: Destination?

  func userDidTapNavigateToNotificationStudyButton() {
    self.destination = .notificationStudy(
      .init(count: 42)
    )
  }
  
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
          self.model.userDidTapNavigateToNotificationStudyButton()
        } label: {
          Label("Notifications Study", systemImage: "envelope")
        }

        Button {
          self.model.userDidTapNavigateToLoggerStudyButton()
        } label: {
          Label("Logger Study", systemImage: "list.dash")
        }

      }
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.notificationStudy
      ) { $model in
        NotificationsStudyView(model: model)
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

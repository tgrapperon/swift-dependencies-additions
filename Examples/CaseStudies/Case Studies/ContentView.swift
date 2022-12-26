import SwiftUI
import SwiftUINavigation

@MainActor
class StudiesModel: ObservableObject {
  enum Destination {
    case notificationStudy(NotificationStudy)
    case loggerStudy(LoggerStudy)
    case swiftUIEnvironmentStudy(SwiftUIEnvironmentStudy)
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

  func userDidTapNavigateToSwiftUIEnvironmentStudyButton() {
    self.destination = .swiftUIEnvironmentStudy(
      .init()
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
          Label("Logger", systemImage: "list.dash")
        }

        Button {
          self.model.userDidTapNavigateToNotificationStudyButton()
        } label: {
          Label("Notifications", systemImage: "envelope")
        }

        Button {
          self.model.userDidTapNavigateToSwiftUIEnvironmentStudyButton()
        } label: {
          Label("SwiftUI Environment", systemImage: "swift")
        }

      }
      .navigationTitle("Case Studies")
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
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.swiftUIEnvironmentStudy
      ) { $model in
        SwiftUIEnvironmentStudyView(model: model)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(model: .init())
  }
}

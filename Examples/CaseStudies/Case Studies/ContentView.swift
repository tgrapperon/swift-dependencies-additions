import Dependencies
import SwiftUI
import SwiftUINavigation

@MainActor
class StudiesModel: ObservableObject {
  @Dependency(\.self) var dependencies

  enum Destination {
    case userDefaultsStudy(UserDefaultsStudy)
    case compression(CompressionStudy)
    case coreDataStudy(CoreDataStudy)
    case notificationStudy(NotificationStudy)
    case loggerStudy(LoggerStudy)
    case swiftUIEnvironmentStudy(SwiftUIEnvironmentStudy)
  }
  @Published var destination: Destination?

  func userDidTapNavigateToUserDefaultsStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .userDefaultsStudy(.init())
    }
  }

  func userDidTapNavigateToCompressionStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .compression(.init())
    }
  }

  func userDidTapNavigateToCoreDataStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .coreDataStudy(.init())
    }
  }

  func userDidTapNavigateToNotificationStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .notificationStudy(.init(count: 42))
    }
  }

  func userDidTapNavigateToLoggerStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .loggerStudy(
        .init(customerName: "Blob")
      )
    }
  }

  func userDidTapNavigateToSwiftUIEnvironmentStudyButton() {
    self.destination = DependencyValues.withValues(from: self) {
      .swiftUIEnvironmentStudy(.init())
    }
  }
}

struct ContentView: View {
  @ObservedObject var model: StudiesModel

  var body: some View {
    NavigationStack {
      List {

        Button {
          self.model.userDidTapNavigateToUserDefaultsStudyButton()
        } label: {
          Label("AppStorage", systemImage: "archivebox")
        }

        Button {
          self.model.userDidTapNavigateToCompressionStudyButton()
        } label: {
          Label("Compression", systemImage: "rectangle.compress.vertical")
        }

        Button {
          self.model.userDidTapNavigateToCoreDataStudyButton()
        } label: {
          Label("Core Data", systemImage: "point.3.connected.trianglepath.dotted")
        }

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
        case: /StudiesModel.Destination.userDefaultsStudy
      ) { $model in
        UserDefaultsStudyView(model: model)
      }
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.compression
      ) { $model in
        CompressionStudyView(model: model)
      }
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.coreDataStudy
      ) { $model in
        CoreDataStudyView(model: model)
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
    ContentView(
      model:
        DependencyValues.withValues {
          $0.userDefaults = .standard
          $0.persistentContainer = .canonical(inMemory: true).withInitialData()
        } operation: {
          .init()
        }
    )
  }
}

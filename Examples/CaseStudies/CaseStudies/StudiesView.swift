import Dependencies
import SwiftUI
import SwiftUINavigation

@MainActor
class StudiesModel: ObservableObject {
  enum Destination {
    case userDefaultsStudy(UserDefaultsStudy)
    case compression(CompressionStudy)
    case coreDataStudy(CoreDataStudy)
    case notificationStudy(CustomNotificationStudy)
    #if os(iOS)
      case batteryStatusStudy(BatteryStatusStudy)
    #endif
    case loggerStudy(LoggerStudy)
    case swiftUIEnvironmentStudy(SwiftUIEnvironmentStudy)
    case userNotifications(UserNotificationsStudy)
  }

  @Dependency(\.self) var dependencies
  @Published var destination: Destination?

  init(destination: Destination? = nil) {
    self.destination = destination
  }

  func userDefaultsStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .userDefaultsStudy(.init())
    }
  }

  func compressionStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .compression(.init())
    }
  }

  func coreDataStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .coreDataStudy(.init())
    }
  }

  func customNotificationStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .notificationStudy(.init(count: 42))
    }
  }

  #if os(iOS)
    func batteryStatusStudyButtonTapped() {
      self.destination = withDependencies(from: self) {
        .batteryStatusStudy(.init())
      }
    }
  #endif

  func loggerStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .loggerStudy(
        .init(customerName: "Blob")
      )
    }
  }

  func swiftUIEnvironmentStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .swiftUIEnvironmentStudy(.init())
    }
  }

  func userNotificationStudyButtonTapped() {
    self.destination = withDependencies(from: self) {
      .userNotifications(.init())
    }
  }
}

struct StudiesView: View {
  @ObservedObject var model: StudiesModel

  var body: some View {
    NavigationStack {
      List {
        Button {
          self.model.userDefaultsStudyButtonTapped()
        } label: {
          Label("AppStorage", systemImage: "archivebox")
        }

        Button {
          self.model.compressionStudyButtonTapped()
        } label: {
          Label("Codable & Compression", systemImage: "rectangle.compress.vertical")
        }

        Button {
          self.model.coreDataStudyButtonTapped()
        } label: {
          Label("Core Data", systemImage: "point.3.connected.trianglepath.dotted")
        }

        Button {
          self.model.loggerStudyButtonTapped()
        } label: {
          Label("Logger", systemImage: "list.dash")
        }

        Section {
          Button {
            self.model.customNotificationStudyButtonTapped()
          } label: {
            Label("Notification center", systemImage: "envelope")
          }
          #if os(iOS)
            Button {
              self.model.batteryStatusStudyButtonTapped()
            } label: {
              Label("Battery Status", systemImage: "battery.75")
            }
          #endif
          Button {
            self.model.userNotificationStudyButtonTapped()
          } label: {
            Label("User notifications", systemImage: "app.badge")
          }
        }

        Button {
          self.model.swiftUIEnvironmentStudyButtonTapped()
        } label: {
          Label("SwiftUI Environment", systemImage: "swift")
        }
      }
      .buttonStyle(.navigation)
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
        CustomNotificationStudyView(model: model)
      }
      #if os(iOS)
        .navigationDestination(
          unwrapping: self.$model.destination,
          case: /StudiesModel.Destination.batteryStatusStudy
        ) { $model in
          BatteryStatusStudyView(model: model)
        }
      #endif
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
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /StudiesModel.Destination.userNotifications
      ) { $model in
        UserNotificationsStudyView(model: model)
      }
    }
  }
}

struct StudiesView_Previews: PreviewProvider {
  static var previews: some View {
    StudiesView(
      model:
        withDependencies {
          $0.userDefaults = .standard
          $0.persistentContainer = .default(inMemory: true)
            .withInitialData()
          #if os(iOS)
            $0.device.$batteryState = .charging
            $0.device.$batteryLevel = 0.72
            $0.device.$isBatteryMonitoringEnabled = .constant(true)
          #endif
        } operation: {
          .init()
        }
    )
  }
}

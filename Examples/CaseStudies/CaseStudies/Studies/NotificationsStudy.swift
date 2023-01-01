import Dependencies
import SwiftUI
import SwiftUINavigation
import _NotificationDependency

extension Notifications {
  @MainActor
  var countNotification: MainActorNotificationOf<Int> {
    let notificationName = Notification.Name("CounterNotification")
    let countValue = "countValue"
    return MainActorNotificationOf(notificationName) { notification in
      (notification.userInfo?[countValue] as? Int) ?? 0
    } embed: { value, notification in
      notification.userInfo = [countValue: value]
    }
  }
}

@MainActor
final class NotificationStudy: ObservableObject {
  @Published var count: Int
  @Published var countFromNotification: Int?

  @Published var batteryLevel: Float = 0
  @Published var batteryState: UIDevice.BatteryState = .unknown

  @Dependency.Notification(\.countNotification) var countNotification
  @Dependency.Notification(\.batteryLevelDidChange) var batteryLevelNotification
  @Dependency.Notification(\.batteryStateDidChange) var batteryStateNotification
  
  @Dependency(\.device) var device
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

  init(count: Int = 0) {
    self.count = count
    // Inject the notifications into the `@Published` properties:
    self.batteryLevelNotification.assign(to: &$batteryLevel)
    self.batteryStateNotification.assign(to: &$batteryState)
    self.countNotification.assign(to: &$countFromNotification)
  }

  func onAppear() {
    self.device.isBatteryMonitoringEnabled = true
  }

  func onDisappear() {
    self.device.isBatteryMonitoringEnabled = false
  }

  func userDidTapIncrementButton() {
    self.count += 1
    // Post the updated value
    self.countNotification.post(self.count)
  }

  func userDidTapDecrementButton() {
    self.count -= 1
    // Post the updated value
    self.countNotification.post(self.count)
  }

  func userDidTapSendRandomNotificationButton() {
    self.withRandomNumberGenerator {
      self.countNotification.post(
        Int.random(in: 0...1_000, using: &$0)
      )
    }
  }
}

struct NotificationsStudyView: View {
  @ObservedObject var model: NotificationStudy

  var body: some View {
    List {
      Section {
        LabeledContent("Battery Level") {
          HStack {
            Text(batteryStateLocalizedText)
            Text(
              model.batteryLevel.formatted(
                .percent.precision(.fractionLength(0)))
            )
            Group {
              if model.batteryLevel > 0.875 {
                Image(systemName: "battery.100")
              } else if model.batteryLevel > 0.625 {
                Image(systemName: "battery.75")
              } else if model.batteryLevel > 0.375 {
                Image(systemName: "battery.50")
              } else if model.batteryLevel > 0.125 {
                Image(systemName: "battery.25")
              } else {
                Image(systemName: "battery.0")
              }
            }
            .symbolRenderingMode(.multicolor)
            .imageScale(.large)
          }
        }
      } header: {
        Text("./batteryLevelDidChange")
          .textCase(.none)
          .monospaced()
      }

      Section {
        Stepper {
          LabeledContent("Count from model", value: self.model.count.formatted())
        } onIncrement: {
          self.model.userDidTapIncrementButton()
        } onDecrement: {
          self.model.userDidTapDecrementButton()
        }
      } header: {
        Text("Model")
      }

      Section {
        LabeledContent(
          "Count from notifications",
          value: self.model.countFromNotification.map {
            $0.formatted()
          } ?? "None")
      } header: {
        Text("./countNotification")
          .textCase(.none)
          .monospaced()
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        self.model.userDidTapSendRandomNotificationButton()
      } label: {
        Label("Send a random notification", systemImage: "dice")
          .frame(minHeight: 33)
          .fontWeight(.medium)
          .padding(.horizontal)
      }
      .listRowInsets(.init())
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity)
    }
    .onAppear {
      model.onAppear()
    }
    .onDisappear {
      model.onDisappear()
    }
    .navigationTitle("Notifications")
  }

  var batteryStateLocalizedText: String {
    switch model.batteryState {
    case .unknown:
      return "Unknown"
    case .unplugged:
      return "Unplugged"
    case .charging:
      return "Charging"
    case .full:
      return "Full"
    @unknown default:
      return "Unknown"
    }
  }
}

struct NotificationsStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      withDependencyValues {
        $0.device.$isBatteryMonitoringEnabled = true
        $0.device.$batteryState = .unplugged
        $0.device.$batteryLevel = 0.67
      } operation: {
        Group {
          let model = NotificationStudy()
          NotificationsStudyView(model: model)
            .task {
              model.batteryStateNotification.post(.unknown)
              model.batteryLevelNotification.post(0)
            }
        }
      }
    }
  }
}

import _NotificationDependency
import Dependencies
import SwiftUI
import SwiftUINavigation

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
  @Dependency.Notification(\.countNotification) var countNotification
  @Dependency.Notification(\.batteryLevelDidChange) var batteryLevelNotification
  @Dependency(\.device) var device
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
  private var notificationsObservation: Task<Void, Never>?
  
  init(count: Int = 0) {
    self.count = count
    // Inject the notifications into the `@Published` properties:
    self.batteryLevelNotification.assign(to: &$batteryLevel)
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
        Int.random(in: 0 ... 1_000, using: &$0)
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
            Text(String(describing: model.device.isBatteryMonitoringEnabled))
            Text(model.batteryLevel.formatted(
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
        LabeledContent("Count from notifications", value: self.model.countFromNotification.map {
          $0.formatted()
        } ?? "None")
      } header: {
        Text("Nofications")
      }
    }
    .safeAreaInset(edge: .bottom) {
      VStack {
        Button {
          NotificationCenter.default.post(name: UIDevice.batteryLevelDidChangeNotification, object: UIDevice.current)
          
        } label: {
          Label("Send a battery notification", systemImage: "dice")
            .frame(minHeight: 33)
            .fontWeight(.medium)
            .padding(.horizontal)
        }
        Button {
          self.model.userDidTapSendRandomNotificationButton()
        } label: {
          Label("Send a random notification", systemImage: "dice")
            .frame(minHeight: 33)
            .fontWeight(.medium)
            .padding(.horizontal)
        }
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
}

struct NotificationsStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WithState(initialValue: Float(0.2)) { $value in
        withDependencyValues {
          $0.device.$batteryLevel = value
        } operation: {
          NotificationsStudyView(model: .init())
        }
        .onChange(of: value) { _ in
          @Dependency(\.notificationCenter) var notificationCenter;
          notificationCenter.post(name: UIDevice.batteryLevelDidChangeNotification)
        }
        .safeAreaInset(edge: .bottom) {
          Slider(value: $value, in: 0 ... 1)
        }
      }
    }
  }
}

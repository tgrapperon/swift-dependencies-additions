import _NotificationDependency
import Dependencies
import SwiftUI
import SwiftUINavigation

extension Notifications {
  var countNotification: NotificationOf<Int> {
    let notificationName = Notification.Name("CounterNotification")
    let countValue = "countValue"
    return NotificationOf(notificationName) { notification in
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
  
  @Dependency.Notification(\.countNotification) var countsNotification
  @Dependency.Notification(\.batteryLevelDidChange) var batteryLevelNotification
  @Dependency(\.device.batteryLevel) var batteryLevelDependency
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
  private var notificationsObservation: Task<Void, Never>?
  
  init(count: Int = 0) {
    self.count = count
//    self.onAppear()
    // Calling onAppear() here instead of the view make it works (poorly), but
    // mostly because the model is constantly recreated, and the update
    // is performed by the initial assignation before the loop.
    // But it shows the kind of effect we'd like to achieve.
  }
  
  func onAppear() {
    // Loop over the notification values to update `countFromNotification`
    self.notificationsObservation = Task { [weak self] in
      guard let self else { return }
      await withTaskGroup(of: Void.self) { group in
        group.addTask { @MainActor in
          for await count in self.countsNotification {
            self.countFromNotification = count
          }
        }
        group.addTask { @MainActor in
          self.batteryLevel = self.batteryLevelDependency
          for await batteryLevel in self.batteryLevelNotification.withCurrentDependencyValues() {
            self.batteryLevel = batteryLevel
          }
        }
        await group.next()
        group.cancelAll()
      }
    }
    // We also send the current value at `onAppear`, so
    // the view starts with an up-to-date value.
    Task {
      // Let the observation above start being effective…
      try await clock.sleep(for: .microseconds(1))
      self.countsNotification.post(self.count)
    }
  }
  
  func onDisappear() {
    self.notificationsObservation?.cancel()
  }
  
  func userDidTapIncrementButton() {
    self.count += 1
    // Post the updated value
    self.countsNotification.post(self.count)
  }
  
  func userDidTapDecrementButton() {
    self.count -= 1
    // Post the updated value
    self.countsNotification.post(self.count)
  }
  
  func userDidTapSendRandomNotificationButton() {
    self.withRandomNumberGenerator {
      self.countsNotification.post(Int.random(in: 0 ... 1_000, using: &$0))
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
}

struct NotificationsStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WithState(initialValue: Float(0.2)) { $value in
        DependencyValues.withValue(\.device.$batteryLevel, value) {
          NotificationsStudyView(model: .init())
        }
        .onChange(of: value) { _ in
          @Dependency(\.notificationCenter) var notificationCenter;
          notificationCenter.post(.init(name: UIDevice.batteryLevelDidChangeNotification))
        }
        .safeAreaInset(edge: .bottom) {
          Slider(value: $value, in: 0 ... 1)
        }
      }
    }
  }
}

import NotificationDependency
import Dependencies
import SwiftUI

extension Notifications {
  var countNotification: NotificationOf<Int> {
    let notificationName = Notification.Name("CounterNotification")
    let countValue = "countValue"
    return NotificationOf(notificationName) {
      ($0.userInfo?[countValue] as? Int) ?? 0
    } notify: { value in
      var notification = Notification(name: notificationName)
      notification.userInfo = [countValue: value]
      return notification
    }
  }
  #if os(iOS)
  var screenshots: NotificationOf<Void> {
    NotificationOf(UIApplication.userDidTakeScreenshotNotification) { notification in () }
  }
  #endif
}

@MainActor
final class NotificationStudy: ObservableObject {
  @Published var count: Int
  @Published var countFromNotification: Int?
  
  @Dependency(\.notifications.countNotification) var countsNotification
  @Dependency(\.continuousClock) var clock
  
  private var notificationObservation: Task<Void, Never>?
  
  init(count: Int = 0) {
    self.count = count
  }
  
  func onAppear() {
    // Loop over the notification values to update `countFromNotification`
    self.notificationObservation = Task { [weak self] in
      guard let self else { return }
      for await count in self.countsNotification() {
        self.countFromNotification = count
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
    self.notificationObservation?.cancel()
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
}

struct NotificationsStudyView: View {
  @ObservedObject var model: NotificationStudy
  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack {
        Text("Count from model")
        Text(self.model.count.formatted())
          .bold()
        Stepper {
          Text("Update model")
        } onIncrement: {
          self.model.userDidTapIncrementButton()
        } onDecrement: {
          self.model.userDidTapDecrementButton()
        }
        .labelsHidden()
      }
      
      VStack {
        Text("Count from notifications")
        Text(
          self.model.countFromNotification.map {
            $0.formatted()
          } ?? "None"
        )
        .bold()
      }
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
      NotificationsStudyView(model: .init())
    }
  }
}

import Dependencies
import _NotificationDependency
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
}

@MainActor
final class NotificationStudy: ObservableObject {
  @Published var count: Int
  @Published var countFromNotification: Int?
  
  @Dependency.Notification(\.countNotification) var countsNotification
  @Dependency(\.continuousClock) var clock
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
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
      NotificationsStudyView(model: .init())
    }
  }
}

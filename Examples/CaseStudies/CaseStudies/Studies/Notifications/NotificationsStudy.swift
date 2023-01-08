import _NotificationDependency
import DependenciesAdditions
import SwiftUI
import SwiftUINavigation

extension Notification.Name {
  static var timerNotification = Notification.Name("TimerNotification")
}

extension Notifications {
  /// A main actor notification of `Int` that is extracted from the
  /// notification's `userInfo` dictionary.
  /// If the notification is illformed (the dictionary doesn't contain
  /// the expected payload), `nil` is returned and no signal is
  /// produced.
  @MainActor
  var countNotification: MainActorNotificationOf<Int> {
    let notificationName = Notification.Name("CounterNotification")
    let countValue = "countValue"
    return MainActorNotificationOf(notificationName) { notification in
      notification.userInfo?[countValue] as? Int
    } embed: { value, notification in
      notification.userInfo = [countValue: value]
    }
  }

  /// A notification of `Date`, each time `.timerNotification` is
  /// posted. `Date` is exctracted from the current `\.date` dependency.
  var timerNotification: NotificationOf<Date> {
    return NotificationOf(.timerNotification) { _ in
      @Dependency(\.date) var date
      return date()
    }
  }
}

@MainActor
final class CustomNotificationStudy: ObservableObject {
  @Published var count: Int
  @Published var countFromNotification: Int?

  @Published var currentDate: Date?

  // A `Notifications.StreamOf<Int>`
  @Dependency.Notification(\.countNotification) var countNotification
  // A `Notifications.StreamOf<Date>`
  @Dependency.Notification(\.timerNotification) var dates

  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
  @Dependency(\.notificationCenter) var notificationCenter
  @Dependency(\.continuousClock) var clock

  private var cancellableTasks = Set<AnyCancellableTask>()

  init(count: Int = 0) {
    self.count = count
    // Inject the notifications into the `@Published` properties:
    self.countNotification.assign(to: &self.$countFromNotification)
    self.dates.assign(to: &self.$currentDate)

    /// Spawn a task that send a `timerNotification` each second, and
    /// that cancels automatically when the model is deinitialized.
    Task { [clock = self.clock, notificationCenter = self.notificationCenter] in
      for await _ in clock.timer(interval: .seconds(1)) {
        notificationCenter.post(name: .timerNotification)
      }
    }
    .store(in: &self.cancellableTasks)
  }

  func incrementButtonTapped() {
    self.count += 1
    // Post the updated value
    self.countNotification.post(self.count)
  }

  func decrementButtonTapped() {
    self.count -= 1
    // Post the updated value
    self.countNotification.post(self.count)
  }

  func sendRandomNotificationButtonTapped() {
    self.withRandomNumberGenerator {
      self.countNotification.post(
        Int.random(in: 0 ... 1_000, using: &$0)
      )
    }
  }
}

extension CustomNotificationStudy {
  @MainActor
  final class ModelA: ObservableObject {
    @Dependency.Notification(\.countNotification) var countNotification

    @Published var count: Int = 0
    init() {
      self.countNotification.assign(to: &self.$count)
    }
  }
}

struct CustomNotificationStudyView: View {
  @ObservedObject var model: CustomNotificationStudy
  var body: some View {
    List {
      Section {
        Stepper {
          LabeledContent("Count from model", value: self.model.count.formatted())
        } onIncrement: {
          self.model.incrementButtonTapped()
        } onDecrement: {
          self.model.decrementButtonTapped()
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
        Text(#"\\.countNotification"#)
          .textCase(.none)
          .monospaced()
      }

      Section {
        LabeledContent(
          "Time",
          value: model.currentDate?.formatted(.dateTime.hour().minute().second())
            ?? "Awaiting first tick")
      } header: {
        Text(#"\\.timerNotification"#)
          .textCase(.none)
          .monospaced()
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        self.model.sendRandomNotificationButtonTapped()
      } label: {
        Label("Send a random `\\.countNotification`", systemImage: "dice")
          .frame(minHeight: 33)
          .fontWeight(.medium)
      }
      .listRowInsets(.init())
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle("Custom Notification")
  }
}

struct CustomNotificationStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CustomNotificationStudyView(model: .init())
    }
  }
}

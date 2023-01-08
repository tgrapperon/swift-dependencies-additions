import Dependencies
import DependenciesAdditionsBasics
import SwiftUI
import UserNotificationsDependency
import UserNotifications

final class UserNotificationsStudy: NSObject, ObservableObject {
  @Dependency(\.userNotificationCenter) var userNotificationCenter
  @Dependency(\.uuid) var uuid
  @Dependency(\.logger) var logger

  @Published var status: UNAuthorizationStatus = .notDetermined
  override init() {
    super.init()
    self.userNotificationCenter.delegate = self
  }

  func onAppear() {
    Task {
      do {
        try await checkNotificationStatus()
      } catch {
        logger.error("Failed to check Notifications status: \(error, privacy: .public)")
      }
    }
  }

  func sendNotificationTapped() {
    Task {
      do {
        try await self.sendNotification()
      } catch {
        logger.error("Failed to send a notification: \(error, privacy: .public)")
      }
    }
  }

  var canSendNotifications: Bool {
    #if os(macOS)
    self.status == .authorized
    #else
    self.status == .authorized || self.status == .ephemeral
    #endif
  }

  @MainActor
  func checkNotificationStatus() async throws {
    let settings = await self.userNotificationCenter.notificationSettings()
    self.status = settings.authorizationStatus

    if self.status == .notDetermined {
      guard
        try await self.userNotificationCenter.requestAuthorization(options: [
          .alert,
        ])
      else {
        return
      }
      self.status = await self.userNotificationCenter.notificationSettings().authorizationStatus
    }
    if self.status == .denied { return }
  }

  func sendNotification() async throws {
    let content = UNMutableNotificationContent()
    content.title = "Hello!"
    content.body = "This is a notification!"
    let identifier = self.uuid().uuidString

    try await self.userNotificationCenter.add(
      .init(
        identifier: identifier,
        content: content,
        trigger: .none
      )
    )
    self.logger.info("Did send notification with id: \(identifier)")
  }
}

extension UserNotificationsStudy: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return .banner
  }
}

struct UserNotificationsStudyView: View {
  @ObservedObject var model: UserNotificationsStudy
  var body: some View {
    List {
      Button("Send a notification") {
        self.model.sendNotificationTapped()
      }
      .disabled(!model.canSendNotifications)
      .onAppear {
        model.onAppear()
      }
    }
    .navigationTitle("User Notifications")
  }
}

struct UserNotificationsStudyView_Previews: PreviewProvider {
  static var previews: some View {
    UserNotificationsStudyView(model: .init())
      .overlay {
        VStack {
          Text("This study doesn't work in SwiftUI Previews")
            .font(.title)
          Divider()
          Text("Launch the app on a device or in the simulator to see notifications")
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
      }
  }
}

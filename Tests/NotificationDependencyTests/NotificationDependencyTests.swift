import Dependencies
import DependenciesAdditions
import NotificationDependency
import XCTest

let notificationName = Notification.Name("SomeNotificationName")

enum NotificationError: Error {
  case extractionFailed
}
func notification(_ int: Int = 0) -> Notification {
  Notification(name: notificationName, object: nil, userInfo: ["": int])
}

extension Notifications {
  var testNotificationWithBidirectionalTransform: ObservationOf<Int> {
    .init(notificationName) {
      guard let value = $0.userInfo?[""] as? Int else {
        throw NotificationError.extractionFailed
      }
      return value
    } notify: {
      notification($0)
    }
  }
  var testNotificationWithUnidirectionalTransform: ObservationOf<Int> {
    .init(notificationName) {
      guard let value = $0.userInfo?[""] as? Int else {
        throw NotificationError.extractionFailed
      }
      return value
    }
  }

  var testNotificationWithoutTransform: ObservationOf<Notification> {
    .init(notificationName)
  }
}

final class NotificationDependencyTests: XCTestCase {

  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
  func testLiveNotifications() async throws {
    @Dependency(\.notifications.testNotificationWithBidirectionalTransform) var testNotification

    try await withTimeout(.seconds(1)) { group in
      group.addTask {
        let expectations = [2, 4, 7, -1]
        var index: Int = 0
        for await value in testNotification() {
          XCTAssertEqual(value, expectations[index])
          index += 1
          if index == expectations.endIndex {
            return
          }
        }
      }
      group.addTask {
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(2)
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(4)
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(7)
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(-1)
      }
    }
  }

  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
  func testLiveNotificationsFailureToExtract() async throws {
    @Dependency(\.notifications.testNotificationWithBidirectionalTransform) var testNotification
    @Dependency(\.notifications) var notificationCenter

    try await withTimeout(.seconds(1)) { group in
      group.addTask {
        let expectations = [2, 4, 7, -1]
        var index: Int = 0
        for await value in testNotification() {
          XCTAssertEqual(value, expectations[index])
          index += 1
          if index == expectations.endIndex {
            return
          }
        }
        // Should have exited after failing to extract the third value
        XCTAssertEqual(index, 2)
      }
      group.addTask {
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(2)
        try await Task.sleep(for: .milliseconds(100))
        testNotification.post(4)
        try await Task.sleep(for: .milliseconds(100))
        notificationCenter.post(.init(name: notificationName))
      }
    }
  }

  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
  func testLiveFailureToSendNotifications() async throws {
    @Dependency(\.notifications.testNotificationWithUnidirectionalTransform) var testNotification;
    
    XCTExpectFailure {
      testNotification.post(2)
    }
  }
}

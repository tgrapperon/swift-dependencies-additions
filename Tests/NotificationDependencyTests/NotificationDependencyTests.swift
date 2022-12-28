import NotificationDependency
import DependenciesAdditions
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
  func testLiveNotifications() async throws {
    @Dependency(\.notifications.testNotificationWithBidirectionalTransform) var testNotification

    try await withTimeout(1000) { group in
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
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(2)
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(4)
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(7)
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(-1)
      }
    }
  }

  func testLiveNotificationsFailureToExtract() async throws {
    @Dependency(\.notifications.testNotificationWithBidirectionalTransform) var testNotification
    @Dependency(\.notifications) var notificationCenter

    try await withTimeout { group in
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
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(2)
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        testNotification.post(4)
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        notificationCenter.post(.init(name: notificationName))
      }
    }
  }

  func testLiveFailureToSendNotifications() async throws {
    @Dependency(\.notifications.testNotificationWithUnidirectionalTransform) var testNotification;
    
    XCTExpectFailure {
      testNotification.post(2)
    }
  }
}

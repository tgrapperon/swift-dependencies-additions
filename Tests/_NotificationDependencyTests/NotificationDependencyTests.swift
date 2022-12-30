import Dependencies
import DependenciesAdditionsTestSupport
import XCTest
import _NotificationDependency

let notificationName = Notification.Name("SomeNotificationName")

func notification(_ int: Int = 0) -> Notification {
  Notification(name: notificationName, object: nil, userInfo: ["": int])
}

extension Notifications {
  var testNotificationWithBidirectionalTransform: NotificationOf<Int> {
    .init(notificationName) {
      $0.userInfo?[""] as? Int
    } embed: {
      $1.userInfo = ["": $0]
    }
  }

  var testNotificationWithoutTransform: NotificationOf<Notification> {
    .init(notificationName)
  }

  var testNotificationWithDependency: NotificationOf<UUID> {
    .init(notificationName) { _ in
      @Dependency(\.uuid) var uuid
      return uuid()
    }
  }
}

final class NotificationDependencyTests: XCTestCase {
  func testLiveNotifications() async throws {
    @Dependency.Notification(\.testNotificationWithBidirectionalTransform) var testNotification
    
    try await withTimeout(1000) { group in
      group.addTask {
        let expectations = [2, 4, 7, -1]
        var index: Int = 0
        for await value in testNotification {
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
    
  func testNotificationCenterUnimplemented() {
    @Dependency(\.notificationCenter) var notificationCenter;

    DependencyValues.withTestValues {
      XCTExpectFailure {
        notificationCenter.post(notification(1))
      }
    }
  }
  
  func testNotificationWithDependency() async throws {
    @Dependency(\.notificationCenter) var notificationCenter
    
    final class Model: @unchecked Sendable {
      @Dependency.Notification(\.testNotificationWithDependency) var notification
    }
    
    let defaultModel = Model()
    let incrementingModel = DependencyValues.withValues {
      $0.uuid = .incrementing
      $0.path.push(1)
    } operation: {
      Model()
    }
    
    let incrementingExpectations = [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000001"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000002"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000003"),
    ]
    
    try await withTimeout(1000) { group in
      group.addTask {
        var index: Int = 0
        for await value in defaultModel.notification {
          XCTAssertNotEqual(value, incrementingExpectations[index])
          index += 1
          if index == incrementingExpectations.endIndex {
            return
          }
        }
      }

      group.addTask {
        var index: Int = 0
        for await value in incrementingModel.notification {
          XCTAssertEqual(value, incrementingExpectations[index])
          index += 1
          if index == incrementingExpectations.endIndex {
            return
          }
        }
      }
      
      group.addTask {
        await DependencyValues.withValue(
          \.uuid,
           .init{ UUID(uuidString: "11111111-1111-1111-1111-111111111111")! }
        ) {
          var index: Int = 0
          for await value in defaultModel.notification.withCurrentDependencyValues() {
            XCTAssertEqual(value, UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            index += 1
            if index == incrementingExpectations.endIndex {
              return
            }
          }
        }
      }
      
      group.addTask {
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        notificationCenter.post(.init(name: notificationName))
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        notificationCenter.post(.init(name: notificationName))
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        notificationCenter.post(.init(name: notificationName))
        try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
        notificationCenter.post(.init(name: notificationName))
      }
    }
  }
}

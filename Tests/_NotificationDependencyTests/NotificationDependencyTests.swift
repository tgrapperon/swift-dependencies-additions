import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import XCTest
import _NotificationDependency
#if canImport(ObjectiveC)
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
    let _ = __dummySeparator__
    await withDependencies {
      $0.context = .live
    } operation: {
      await withTimeout(1000) { group in
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
          await testNotification.post(2)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          await testNotification.post(4)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          await testNotification.post(7)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          await testNotification.post(-1)
        }
      }
    }
  }

  //  func testNotificationCenterUnimplemented() {
  //    @Dependency(\.notificationCenter) var notificationCenter
  //    let _ = __dummySeparator__
  //    XCTExpectFailure {
  //      notificationCenter.post(name: notificationName)
  //    }
  //  }

  func testNotificationWithDependency() async throws {
    @Dependency(\.notificationCenter) var notificationCenter

    final class Model: @unchecked Sendable {
      @Dependency.Notification(\.testNotificationWithDependency) var notification
    }

    let defaultModel = withDependencies {
      $0.context = .live
    } operation: {
      Model()
    }

    let incrementingModel = withDependencies {
      $0.context = .live
      $0.uuid = .incrementing
    } operation: {
      Model()
    }

    let incrementingExpectations = [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000001"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000002"),
      UUID(uuidString: "00000000-0000-0000-0000-000000000003"),
    ]

    await withTimeout(1000) { group in
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
        await withDependencies {
          $0.notificationCenter = .default
          $0.uuid = .init { UUID(uuidString: "11111111-1111-1111-1111-111111111111")! }
        } operation: {
          var index: Int = 0
          for await value in defaultModel.notification.withCurrentDependencies() {
            XCTAssertEqual(value, UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            index += 1
            if index == incrementingExpectations.endIndex {
              return
            }
          }
        }
      }

      group.addTask {
        try await withDependencies {
          $0.notificationCenter = .default
        } operation: {
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          notificationCenter.post(name: notificationName)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          notificationCenter.post(name: notificationName)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          notificationCenter.post(name: notificationName)
          try await Task.sleep(nanoseconds: 100 * NSEC_PER_MSEC)
          notificationCenter.post(name: notificationName)
        }
      }
    }
  }
}
#endif

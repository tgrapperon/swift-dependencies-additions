import Dependencies
import DependenciesAdditionsTestSupport
import NotificationCenterDependency
import XCTest

final class NotificationCenterDependencyTests: XCTestCase {
  func notificationName1() -> Notification.Name { .init("NotificationCenterDependencyTests_1") }
  func notificationName2() -> Notification.Name { .init("NotificationCenterDependencyTests_2") }

  // TODO: Strenghten this
  func testNotificationCenterStream() async throws {
    @Dependency(\.notificationCenter) var notificationCenter
    let n1 = self.notificationName1()
    let n2 = self.notificationName2()
    try await withDependencyValues {
      $0.notificationCenter = .default
    } operation: {
      try await withTimeout { group in
        group.addTask {
          var count = 0
          for await notification in notificationCenter.notifications(named: n1) {
            XCTAssertEqual(notification.name, n1)
            count += 1
            if count == 3 { break }
          }
        }
        group.addTask {
          // Let the subscription above be active
          try await Task.sleep(nanoseconds: NSEC_PER_MSEC)
          // This hops and allows notifications to be delivered
          await MainActor.run {
            notificationCenter.post(name: n1)
          }
          await MainActor.run {
            notificationCenter.post(name: n2)
          }
          await MainActor.run {
            notificationCenter.post(name: n1)
          }
          await MainActor.run {
            notificationCenter.post(name: n1)
          }
        }
      }
    }
  }
}

import Dependencies
import Foundation
import UserNotificationsDependency
import XCTest

final class UserNotificationsDependencyTests: XCTestCase {
  #if (os(iOS) || os(macOS) || os(watchOS) || os(visionOS)) && DEBUG
    @Dependency(\.userNotificationCenter) var notifications
    // This one `fatalError`'s, as we can't build a placeholder.
    //  func testUnimplmentedNotificationSettings() async {
    //    XCTExpectFailure {
    //      let _ = await notifications.notificationSettings()
    //    }
    //  }

    func testUnimplementedDelegate() {
      XCTExpectFailure {
        let _ = notifications.delegate
      }
    }

    func testUnimplementedSupportsContentExtensions() {
      XCTExpectFailure {
        let _ = notifications.supportsContentExtensions
      }
    }

    @available(iOS 16.0, macOS 13, *)
    func testUnimplmentedSetBadgeCount() async throws {
      //    XCTExpectFailure {
      //      let _ = try await notifications.setBadgeCount(0)
      //    }
    }
    func testUnimplmentedRequestAuthorization() async throws {
      //    XCTExpectFailure {
      //      let _ = try await notifications.requestAuthorization()
      //    }
    }
    func testUnimplmentedAdd() async throws {
      //    XCTExpectFailure {
      //      let _ = try await notifications.add(.init(identifier: "", content: .init(), trigger: nil))
      //    }
    }
    func testUnimplmentedPendingNotificationRequests() async {
      //    XCTExpectFailure {
      //      let _ = await notifications.pendingNotificationRequests()
      //    }
    }
    func testUnimplmentedRemovePendingNotificationRequests() {
      XCTExpectFailure {
        let _ = notifications.removePendingNotificationRequests(withIdentifiers: [])
      }
    }
    func testUnimplmentedRemoveAllPendingNotificationRequests() {
      XCTExpectFailure {
        let _ = notifications.removeAllPendingNotificationRequests()
      }
    }
    func testUnimplmentedDeliveredNotifications() async {
      //    XCTExpectFailure {
      //      let _ = await notifications.deliveredNotifications()
      //    }
    }
    func testUnimplmentedRemoveDeliveredNotifications() {
      XCTExpectFailure {
        let _ = notifications.removeDeliveredNotifications(withIdentifiers: [])
      }
    }
    func testUnimplmentedRemoveAllDeliveredNotifications() {
      XCTExpectFailure {
        let _ = notifications.removeAllDeliveredNotifications()
      }
    }
    func testUnimplmentedSetNotificationCategories() {
      XCTExpectFailure {
        let _ = notifications.setNotificationCategories([])
      }
    }
    func testUnimplmentedNotificationCategories() async {
      //    XCTExpectFailure {
      //      let _ = await notifications.notificationCategories()
      //    }
    }
  #endif
}

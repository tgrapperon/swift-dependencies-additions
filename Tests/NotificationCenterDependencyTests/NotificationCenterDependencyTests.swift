#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import NotificationCenterDependency
  import XCTest
  final class NotificationCenterDependencyTests: XCTestCase {
    nonisolated
      func notificationName1() -> Notification.Name
    { .init("NotificationCenterDependencyTests_1") }
    nonisolated
      func notificationName2() -> Notification.Name
    { .init("NotificationCenterDependencyTests_2") }

    // TODO: Strenghten this
    @MainActor
    func testNotificationCenterStream() async throws {
      @Dependency(\.notificationCenter) var notificationCenter: NotificationCenter.Dependency

      let n1 = self.notificationName1()
      let n2 = self.notificationName2()
      await withDependencies {
        $0.notificationCenter = .default
      } operation: {
        await withTimeout { group in
          group.addTask {
            var count = 0
            let notifications = await MainActor.run {
              UncheckedSendable(notificationCenter.notifications(named: n1))
            }.value
            for await notification in notifications {
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

    #if DEBUG
      func testNotificationCenterFailure1() {
        @Dependency(\.notificationCenter) var notificationCenter: NotificationCenter.Dependency
        XCTExpectFailure {
          notificationCenter.post(name: notificationName1())
        }
      }

      func testNotificationCenterFailure2() {
        @Dependency(\.notificationCenter) var notificationCenter
        class O: NSObject {
          @objc func f(_ n: Any) {}
        }
        XCTExpectFailure {
          notificationCenter.addObserver(
            O(),
            selector: #selector(O.f(_:)),
            name: notificationName1(),
            object: nil
          )
        }
      }

      func testNotificationCenterFailure3() {
        @Dependency(\.notificationCenter) var notificationCenter: NotificationCenter.Dependency
        XCTExpectFailure {
          notificationCenter.removeObserver(self)
        }
      }

      func testNotificationCenterFailure4() {
        @Dependency(\.notificationCenter) var notificationCenter: NotificationCenter.Dependency
        XCTExpectFailure {
          _ = notificationCenter.notifications(named: notificationName1())
        }
      }

      func testNotificationCenterFailure5() {
        @Dependency(\.notificationCenter) var notificationCenter: NotificationCenter.Dependency
        XCTExpectFailure {
          _ = notificationCenter.publisher(for: notificationName1())
        }
      }

    #endif
  }
#endif

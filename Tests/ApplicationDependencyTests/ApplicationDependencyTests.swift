import ApplicationDependency
import Dependencies
import XCTest

#if os(iOS) || os(tvOS)
  @MainActor
  final class ApplicationDependencyTests: XCTestCase {
    @Dependency(\.application) var application

    func testApplicationIOS() {
      withDependencies {
        $0.application.$supportsMultipleScenes = true
      } operation: {
        XCTAssertEqual(application.supportsMultipleScenes, true)
      }
    }

    @MainActor
    func testModel() {
      @MainActor
      class Model {
        @Dependency(\.application) var application

        func incrementBadgeNumber() {
          self.application.applicationIconBadgeNumber += 1
        }
      }

      let badgeNumber = LockIsolated(5)
      withDependencies {
        $0.application.$applicationIconBadgeNumber = .init(badgeNumber)
      } operation: {
        let model = Model()
        model.incrementBadgeNumber()
        XCTAssertEqual(6, model.application.applicationIconBadgeNumber)
      }
    }

    func testFailingTestApplicationIOS_delegate() {
      XCTExpectFailure {
        let _ = application.delegate
      }
    }

    func testFailingTestApplicationIOS_isIdleTimerDisabled() {
      XCTExpectFailure {
        let _ = application.isIdleTimerDisabled
      }
    }

    func testFailingTestApplicationIOS_canOpenURL() {
      XCTExpectFailure {
        let _ = application.canOpenURL(FileManager.default.temporaryDirectory)
      }
    }

    func testFailingTestApplicationIOS_open() async {
      //      XCTExpectFailure {
      //        let _ = await application.`open`(FileManager.default.temporaryDirectory)
      //      }
    }

    func testFailingTestApplicationIOS_sendEvent() {
      XCTExpectFailure {
        let _ = application.sendEvent(.init())
      }
    }

    func testFailingTestApplicationIOS_sendAction() {
      XCTExpectFailure {
        let _ = application.sendAction(
          #selector(UIApplication.supportedInterfaceOrientations(for:)), to: nil, from: nil,
          for: nil)
      }
    }

    func testFailingTestApplicationIOS_supportedInterfaceOrientations() {
      XCTExpectFailure {
        let _ = application.supportedInterfaceOrientations(for: nil)
      }
    }

    func testFailingTestApplicationIOS_applicationIconBadgeNumber() {
      XCTExpectFailure {
        let _ = application.applicationIconBadgeNumber
      }
    }

    func testFailingTestApplicationIOS_applicationSupportsShakeToEdit() {
      XCTExpectFailure {
        let _ = application.applicationSupportsShakeToEdit
      }
    }

    func testFailingTestApplicationIOS_applicationState() {
      XCTExpectFailure {
        let _ = application.applicationState
      }
    }

    func testFailingTestApplicationIOS_backgroundTimeRemaining() {
      XCTExpectFailure {
        let _ = application.backgroundTimeRemaining
      }
    }

    func testFailingTestApplicationIOS_beginBackgroundTask() {
      XCTExpectFailure {
        let _ = application.beginBackgroundTask()
      }
    }

    func testFailingTestApplicationIOS_endBackgroundTask() {
      XCTExpectFailure {
        let _ = application.endBackgroundTask(.invalid)
      }
    }

    func testFailingTestApplicationIOS_backgroundRefreshStatus() {
      XCTExpectFailure {
        let _ = application.backgroundRefreshStatus
      }
    }

    func testFailingTestApplicationIOS_isProtectedDataAvailable() {
      XCTExpectFailure {
        let _ = application.isProtectedDataAvailable
      }
    }

    func testFailingTestApplicationIOS_userInterfaceLayoutDirection() {
      XCTExpectFailure {
        let _ = application.userInterfaceLayoutDirection
      }
    }

    func testFailingTestApplicationIOS_preferredContentSizeCategory() {
      XCTExpectFailure {
        let _ = application.preferredContentSizeCategory
      }
    }

    func testFailingTestApplicationIOS_connectedScenes() {
      XCTExpectFailure {
        let _ = application.connectedScenes
      }
    }

    func testFailingTestApplicationIOS_openSessions() {
      XCTExpectFailure {
        let _ = application.openSessions
      }
    }

    func testFailingTestApplicationIOS_supportsMultipleScenes() {
      XCTExpectFailure {
        let _ = application.supportsMultipleScenes
      }
    }

    func testFailingTestApplicationIOS_requestSceneSessionActivation() {
      XCTExpectFailure {
        let _ = application.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
      }
    }

    func testFailingTestApplicationIOS_requestSceneSessionDestruction() {
      //      XCTExpectFailure {
      //        let _ = application.requestSceneSessionDestruction(UISceneSession, options: nil)
      //      }
    }

    func testFailingTestApplicationIOS_requestSceneSessionRefresh() {
      //      XCTExpectFailure {
      //        let _ = application.requestSceneSessionRefresh(UISceneSession)
      //      }
    }

    func testFailingTestApplicationIOS_registerForRemoteNotifications() {
      XCTExpectFailure {
        let _ = application.registerForRemoteNotifications()
      }
    }

    func testFailingTestApplicationIOS_unregisterForRemoteNotifications() {
      XCTExpectFailure {
        let _ = application.unregisterForRemoteNotifications()
      }
    }

    func testFailingTestApplicationIOS_isRegisteredForRemoteNotifications() {
      XCTExpectFailure {
        let _ = application.isRegisteredForRemoteNotifications
      }
    }

    func testFailingTestApplicationIOS_beginReceivingRemoteControlEvents() {
      XCTExpectFailure {
        let _ = application.beginReceivingRemoteControlEvents()
      }
    }

    func testFailingTestApplicationIOS_endReceivingRemoteControlEvents() {
      XCTExpectFailure {
        let _ = application.endReceivingRemoteControlEvents()
      }
    }

    func testFailingTestApplicationIOS_shortcutItems() {
      XCTExpectFailure {
        let _ = application.shortcutItems
      }
    }

    func testFailingTestApplicationIOS_supportsAlternateIcons() {
      XCTExpectFailure {
        let _ = application.supportsAlternateIcons
      }
    }

    func testFailingTestApplicationIOS_setAlternateIconName() async {
      //      XCTExpectFailure {
      //        let _ = await application.setAlternateIconName(nil)
      //      }
    }

    func testFailingTestApplicationIOS_alternateIconName() {
      XCTExpectFailure {
        let _ = application.alternateIconName
      }
    }

    func testFailingTestApplicationIOS_extendStateRestoration() {
      XCTExpectFailure {
        let _ = application.extendStateRestoration()
      }
    }

    func testFailingTestApplicationIOS_completeStateRestoration() {
      XCTExpectFailure {
        let _ = application.completeStateRestoration()
      }
    }

    func testFailingTestApplicationIOS_ignoreSnapshotOnNextApplicationLaunch() {
      XCTExpectFailure {
        let _ = application.ignoreSnapshotOnNextApplicationLaunch()
      }
    }

  }
#endif

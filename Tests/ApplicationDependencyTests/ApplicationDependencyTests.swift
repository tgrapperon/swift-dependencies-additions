import ApplicationDependency
import Dependencies
import XCTest

#if os(iOS) || os(tvOS) || os(visionOS)
  final class ApplicationDependencyTests: XCTestCase {
    @Dependency(\.application) var application
    @MainActor
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
    #if DEBUG
      @MainActor
      func testFailingTestApplicationIOS_delegate() {
        XCTExpectFailure {
          let _ = application.delegate
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_isIdleTimerDisabled() {
        XCTExpectFailure {
          let _ = application.isIdleTimerDisabled
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_canOpenURL() {
        XCTExpectFailure {
          let _ = application.canOpenURL(FileManager.default.temporaryDirectory)
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_open() async {
        //      XCTExpectFailure {
        //        let _ = await application.`open`(FileManager.default.temporaryDirectory)
        //      }
      }
      @MainActor
      func testFailingTestApplicationIOS_sendEvent() {
        XCTExpectFailure {
          let _ = application.sendEvent(.init())
        }
      }

      #if os(iOS)
        @MainActor
        func testFailingTestApplicationIOS_sendAction() {
          XCTExpectFailure {
            let _ = application.sendAction(
              #selector(UIApplication.supportedInterfaceOrientations(for:)), to: nil, from: nil,
              for: nil)
          }
        }
      #endif

      #if os(iOS)
        @MainActor
        func testFailingTestApplicationIOS_supportedInterfaceOrientations() {
          XCTExpectFailure {
            let _ = application.supportedInterfaceOrientations(for: nil)
          }
        }
      #endif

      @MainActor
      func testFailingTestApplicationIOS_applicationIconBadgeNumber() {
        XCTExpectFailure {
          let _ = application.applicationIconBadgeNumber
        }
      }

      #if os(iOS)
        @MainActor
        func testFailingTestApplicationIOS_applicationSupportsShakeToEdit() {
          XCTExpectFailure {
            let _ = application.applicationSupportsShakeToEdit
          }
        }
      #endif
      @MainActor
      func testFailingTestApplicationIOS_applicationState() {
        XCTExpectFailure {
          let _ = application.applicationState
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_backgroundTimeRemaining() {
        XCTExpectFailure {
          let _ = application.backgroundTimeRemaining
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_beginBackgroundTask() {
        XCTExpectFailure {
          let _ = application.beginBackgroundTask()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_endBackgroundTask() {
        XCTExpectFailure {
          let _ = application.endBackgroundTask(.invalid)
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_backgroundRefreshStatus() {
        XCTExpectFailure {
          let _ = application.backgroundRefreshStatus
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_isProtectedDataAvailable() {
        XCTExpectFailure {
          let _ = application.isProtectedDataAvailable
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_userInterfaceLayoutDirection() {
        XCTExpectFailure {
          let _ = application.userInterfaceLayoutDirection
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_preferredContentSizeCategory() {
        XCTExpectFailure {
          let _ = application.preferredContentSizeCategory
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_connectedScenes() {
        XCTExpectFailure {
          let _ = application.connectedScenes
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_openSessions() {
        XCTExpectFailure {
          let _ = application.openSessions
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_supportsMultipleScenes() {
        XCTExpectFailure {
          let _ = application.supportsMultipleScenes
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_requestSceneSessionActivation() {
        XCTExpectFailure {
          let _ = application.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_requestSceneSessionDestruction() {
        //      XCTExpectFailure {
        //        let _ = application.requestSceneSessionDestruction(UISceneSession, options: nil)
        //      }
      }
      @MainActor
      func testFailingTestApplicationIOS_requestSceneSessionRefresh() {
        //      XCTExpectFailure {
        //        let _ = application.requestSceneSessionRefresh(UISceneSession)
        //      }
      }
      @MainActor
      func testFailingTestApplicationIOS_registerForRemoteNotifications() {
        XCTExpectFailure {
          let _ = application.registerForRemoteNotifications()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_unregisterForRemoteNotifications() {
        XCTExpectFailure {
          let _ = application.unregisterForRemoteNotifications()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_isRegisteredForRemoteNotifications() {
        XCTExpectFailure {
          let _ = application.isRegisteredForRemoteNotifications
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_beginReceivingRemoteControlEvents() {
        XCTExpectFailure {
          let _ = application.beginReceivingRemoteControlEvents()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_endReceivingRemoteControlEvents() {
        XCTExpectFailure {
          let _ = application.endReceivingRemoteControlEvents()
        }
      }

      #if os(iOS)
        @MainActor
        func testFailingTestApplicationIOS_shortcutItems() {
          XCTExpectFailure {
            let _ = application.shortcutItems
          }
        }
      #endif

      @MainActor
      func testFailingTestApplicationIOS_supportsAlternateIcons() {
        XCTExpectFailure {
          let _ = application.supportsAlternateIcons
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_setAlternateIconName() async {
        //      XCTExpectFailure {
        //        let _ = await application.setAlternateIconName(nil)
        //      }
      }
      @MainActor
      func testFailingTestApplicationIOS_alternateIconName() {
        XCTExpectFailure {
          let _ = application.alternateIconName
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_extendStateRestoration() {
        XCTExpectFailure {
          let _ = application.extendStateRestoration()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_completeStateRestoration() {
        XCTExpectFailure {
          let _ = application.completeStateRestoration()
        }
      }
      @MainActor
      func testFailingTestApplicationIOS_ignoreSnapshotOnNextApplicationLaunch() {
        XCTExpectFailure {
          let _ = application.ignoreSnapshotOnNextApplicationLaunch()
        }
      }
    #endif
  }
#endif

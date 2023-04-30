import Dependencies
import DeviceDependency
import XCTest

#if os(iOS)
  final class DeviceDependencyTests: XCTestCase {
    @Dependency(\.device) var device

    @MainActor
    func testDeviceIOS() {
      withDependencies {
        $0.device.$batteryLevel = 42
      } operation: {
        XCTAssertEqual(device.batteryLevel, 42)
      }
    }
#if DEBUG
    @MainActor
    func testFailingTestDeviceIOS_name() {
      XCTExpectFailure {
        let _ = device.name
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_model() {
      XCTExpectFailure {
        let _ = device.model
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_localizedModel() {
      XCTExpectFailure {
        let _ = device.localizedModel
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_systemName() {
      XCTExpectFailure {
        let _ = device.systemName
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_systemVersion() {
      XCTExpectFailure {
        let _ = device.systemVersion
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_identifierForVendor() {
      XCTExpectFailure {
        let _ = device.identifierForVendor
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_orientation() {
      XCTExpectFailure {
        let _ = device.orientation
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_isGeneratingDeviceOrientationNotifications() {
      XCTExpectFailure {
        let _ = device.isGeneratingDeviceOrientationNotifications
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_beginGeneratingDeviceOrientationNotifications() {
      XCTExpectFailure {
        let _ = device.beginGeneratingDeviceOrientationNotifications()
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_endGeneratingDeviceOrientationNotifications() {
      XCTExpectFailure {
        let _ = device.endGeneratingDeviceOrientationNotifications()
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_isBatteryMonitoringEnabled() {
      XCTExpectFailure {
        let _ = device.isBatteryMonitoringEnabled
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_batteryState() {
      XCTExpectFailure {
        let _ = device.batteryState
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_batteryLevel() {
      XCTExpectFailure {
        let _ = device.batteryLevel
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_isProximityMonitoringEnabled() {
      XCTExpectFailure {
        let _ = device.isProximityMonitoringEnabled
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_proximityState() {
      XCTExpectFailure {
        let _ = device.proximityState
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_isMultitaskingSupported() {
      XCTExpectFailure {
        let _ = device.isMultitaskingSupported
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_userInterfaceIdiom() {
      XCTExpectFailure {
        let _ = device.userInterfaceIdiom
      }
    }
    @MainActor
    func testFailingTestDeviceIOS_playInputClick() {
      XCTExpectFailure {
        let _ = device.playInputClick()
      }
    }
    #endif
  }
#endif

#if os(watchOS)
  @MainActor
  final class DeviceDependencyTests: XCTestCase {
    @Dependency(\.device) var device

#if DEBUG
    @MainActor
    func testFailingTestDeviceWatchOS_name() {
      XCTExpectFailure {
        let _ = device.name
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_model() {
      XCTExpectFailure {
        let _ = device.model
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_localizedModel() {
      XCTExpectFailure {
        let _ = device.localizedModel
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_systemName() {
      XCTExpectFailure {
        let _ = device.systemName
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_systemVersion() {
      XCTExpectFailure {
        let _ = device.systemVersion
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_identifierForVendor() {
      XCTExpectFailure {
        let _ = device.identifierForVendor
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_screenBounds() {
      XCTExpectFailure {
        let _ = device.screenBounds
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_screenScale() {
      XCTExpectFailure {
        let _ = device.screenScale
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_preferredContentSizeCategory() {
      XCTExpectFailure {
        let _ = device.preferredContentSizeCategory
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_layoutDirection() {
      XCTExpectFailure {
        let _ = device.layoutDirection
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_wristLocation() {
      XCTExpectFailure {
        let _ = device.wristLocation
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_crownOrientation() {
      XCTExpectFailure {
        let _ = device.crownOrientation
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_isBatteryMonitoringEnabled() {
      XCTExpectFailure {
        let _ = device.isBatteryMonitoringEnabled
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_batteryState() {
      XCTExpectFailure {
        let _ = device.batteryState
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_batteryLevel() {
      XCTExpectFailure {
        let _ = device.batteryLevel
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_waterResistanceRating() {
      XCTExpectFailure {
        let _ = device.waterResistanceRating
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_isWaterLockEnabled() {
      XCTExpectFailure {
        let _ = device.isWaterLockEnabled
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_supportsAudioStreaming() {
      XCTExpectFailure {
        let _ = device.supportsAudioStreaming
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_play() {
      XCTExpectFailure {
        let _ = device.play(.click)
      }
    }
    @MainActor
    func testFailingTestDeviceWatchOS_enableWaterLock() {
      XCTExpectFailure {
        let _ = device.enableWaterLock()
      }
    }
    #endif
  }
#endif

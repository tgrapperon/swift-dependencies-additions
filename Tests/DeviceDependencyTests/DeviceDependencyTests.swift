import Dependencies
import DeviceDependency
import XCTest

#if os(iOS) 
  @MainActor
  final class DeviceDependencyTests: XCTestCase {
    @Dependency(\.device) var device

    func testDeviceIOS() {
      withDependencies {
        $0.device.$batteryLevel = 42
      } operation: {
        XCTAssertEqual(device.batteryLevel, 42)
      }
    }

//    func testFailingTestDeviceIOS_name() {
//      XCTExpectFailure {
//        let _ = device.name
//      }
//    }
//    func testFailingTestDeviceIOS_model() {
//      XCTExpectFailure {
//        let _ = device.model
//      }
//    }
//    func testFailingTestDeviceIOS_localizedModel() {
//      XCTExpectFailure {
//        let _ = device.localizedModel
//      }
//    }
//    func testFailingTestDeviceIOS_systemName() {
//      XCTExpectFailure {
//        let _ = device.systemName
//      }
//    }
//    func testFailingTestDeviceIOS_systemVersion() {
//      XCTExpectFailure {
//        let _ = device.systemVersion
//      }
//    }
//    func testFailingTestDeviceIOS_identifierForVendor() {
//      XCTExpectFailure {
//        let _ = device.identifierForVendor
//      }
//    }
//    func testFailingTestDeviceIOS_orientation() {
//      XCTExpectFailure {
//        let _ = device.orientation
//      }
//    }
//    func testFailingTestDeviceIOS_isGeneratingDeviceOrientationNotifications() {
//      XCTExpectFailure {
//        let _ = device.isGeneratingDeviceOrientationNotifications
//      }
//    }
//    func testFailingTestDeviceIOS_beginGeneratingDeviceOrientationNotifications() {
//      XCTExpectFailure {
//        let _ = device.beginGeneratingDeviceOrientationNotifications()
//      }
//    }
//    func testFailingTestDeviceIOS_endGeneratingDeviceOrientationNotifications() {
//      XCTExpectFailure {
//        let _ = device.endGeneratingDeviceOrientationNotifications()
//      }
//    }
//    func testFailingTestDeviceIOS_isBatteryMonitoringEnabled() {
//      XCTExpectFailure {
//        let _ = device.isBatteryMonitoringEnabled
//      }
//    }
//    func testFailingTestDeviceIOS_batteryState() {
//      XCTExpectFailure {
//        let _ = device.batteryState
//      }
//    }
//    func testFailingTestDeviceIOS_batteryLevel() {
//      XCTExpectFailure {
//        let _ = device.batteryLevel
//      }
//    }
//    func testFailingTestDeviceIOS_isProximityMonitoringEnabled() {
//      XCTExpectFailure {
//        let _ = device.isProximityMonitoringEnabled
//      }
//    }
//    func testFailingTestDeviceIOS_proximityState() {
//      XCTExpectFailure {
//        let _ = device.proximityState
//      }
//    }
//    func testFailingTestDeviceIOS_isMultitaskingSupported() {
//      XCTExpectFailure {
//        let _ = device.isMultitaskingSupported
//      }
//    }
//    func testFailingTestDeviceIOS_userInterfaceIdiom() {
//      XCTExpectFailure {
//        let _ = device.userInterfaceIdiom
//      }
//    }
//    func testFailingTestDeviceIOS_playInputClick() {
//      XCTExpectFailure {
//        let _ = device.playInputClick()
//      }
//    }

  }
#endif

#if os(watchOS)
  @MainActor
  final class DeviceDependencyTests: XCTestCase {
    @Dependency(\.device) var device

//    func testFailingTestDeviceWatchOS_name() {
//      XCTExpectFailure {
//        let _ = device.name
//      }
//    }
//    func testFailingTestDeviceWatchOS_model() {
//      XCTExpectFailure {
//        let _ = device.model
//      }
//    }
//    func testFailingTestDeviceWatchOS_localizedModel() {
//      XCTExpectFailure {
//        let _ = device.localizedModel
//      }
//    }
//    func testFailingTestDeviceWatchOS_systemName() {
//      XCTExpectFailure {
//        let _ = device.systemName
//      }
//    }
//    func testFailingTestDeviceWatchOS_systemVersion() {
//      XCTExpectFailure {
//        let _ = device.systemVersion
//      }
//    }
//    func testFailingTestDeviceWatchOS_identifierForVendor() {
//      XCTExpectFailure {
//        let _ = device.identifierForVendor
//      }
//    }
//    func testFailingTestDeviceWatchOS_screenBounds() {
//      XCTExpectFailure {
//        let _ = device.screenBounds
//      }
//    }
//    func testFailingTestDeviceWatchOS_screenScale() {
//      XCTExpectFailure {
//        let _ = device.screenScale
//      }
//    }
//    func testFailingTestDeviceWatchOS_preferredContentSizeCategory() {
//      XCTExpectFailure {
//        let _ = device.preferredContentSizeCategory
//      }
//    }
//    func testFailingTestDeviceWatchOS_layoutDirection() {
//      XCTExpectFailure {
//        let _ = device.layoutDirection
//      }
//    }
//    func testFailingTestDeviceWatchOS_wristLocation() {
//      XCTExpectFailure {
//        let _ = device.wristLocation
//      }
//    }
//    func testFailingTestDeviceWatchOS_crownOrientation() {
//      XCTExpectFailure {
//        let _ = device.crownOrientation
//      }
//    }
//    func testFailingTestDeviceWatchOS_isBatteryMonitoringEnabled() {
//      XCTExpectFailure {
//        let _ = device.isBatteryMonitoringEnabled
//      }
//    }
//    func testFailingTestDeviceWatchOS_batteryState() {
//      XCTExpectFailure {
//        let _ = device.batteryState
//      }
//    }
//    func testFailingTestDeviceWatchOS_batteryLevel() {
//      XCTExpectFailure {
//        let _ = device.batteryLevel
//      }
//    }
//    func testFailingTestDeviceWatchOS_waterResistanceRating() {
//      XCTExpectFailure {
//        let _ = device.waterResistanceRating
//      }
//    }
//    func testFailingTestDeviceWatchOS_isWaterLockEnabled() {
//      XCTExpectFailure {
//        let _ = device.isWaterLockEnabled
//      }
//    }
//    func testFailingTestDeviceWatchOS_supportsAudioStreaming() {
//      XCTExpectFailure {
//        let _ = device.supportsAudioStreaming
//      }
//    }
//    func testFailingTestDeviceWatchOS_play() {
//      XCTExpectFailure {
//        let _ = device.play(.click)
//      }
//    }
//    func testFailingTestDeviceWatchOS_enableWaterLock() {
//      XCTExpectFailure {
//        let _ = device.enableWaterLock()
//      }
//    }

  }
#endif

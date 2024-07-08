#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  import Dependencies
  import ProcessInfoDependency
  import XCTest

  final class ProcessInfoDependencyTests: XCTestCase {
    @Dependency(\.processInfo) var processInfo

    func testProcessInfoConfiguration() {
      withDependencies {
        $0.processInfo.$processorCount = 128
      } operation: {
        XCTAssertEqual(processInfo.processorCount, 128)
      }
    }
    #if DEBUG
      func testFailingTestProcessInfo_environment() {
        XCTExpectFailure {
          let _ = processInfo.environment
        }
      }
      func testFailingTestProcessInfo_arguments() {
        XCTExpectFailure {
          let _ = processInfo.arguments
        }
      }
      func testFailingTestProcessInfo_hostName() {
        XCTExpectFailure {
          let _ = processInfo.hostName
        }
      }
      func testFailingTestProcessInfo_processName() {
        XCTExpectFailure {
          let _ = processInfo.processName
        }
      }
      func testFailingTestProcessInfo_processIdentifier() {
        XCTExpectFailure {
          let _ = processInfo.processIdentifier
        }
      }
      func testFailingTestProcessInfo_globallyUniqueString() {
        XCTExpectFailure {
          let _ = processInfo.globallyUniqueString
        }
      }
      func testFailingTestProcessInfo_operatingSystemVersionString() {
        XCTExpectFailure {
          let _ = processInfo.operatingSystemVersionString
        }
      }
      func testFailingTestProcessInfo_operatingSystemVersion() {
        XCTExpectFailure {
          let _ = processInfo.operatingSystemVersion
        }
      }
      func testFailingTestProcessInfo_processorCount() {
        XCTExpectFailure {
          let _ = processInfo.processorCount
        }
      }
      func testFailingTestProcessInfo_activeProcessorCount() {
        XCTExpectFailure {
          let _ = processInfo.activeProcessorCount
        }
      }
      func testFailingTestProcessInfo_physicalMemory() {
        XCTExpectFailure {
          let _ = processInfo.physicalMemory
        }
      }
      func testFailingTestProcessInfo_systemUptime() {
        XCTExpectFailure {
          let _ = processInfo.systemUptime
        }
      }
      func testFailingTestProcessInfo_thermalState() {
        XCTExpectFailure {
          let _ = processInfo.thermalState
        }
      }
      func testFailingTestProcessInfo_isLowPowerModeEnabled() {
        XCTExpectFailure {
          let _ = processInfo.isLowPowerModeEnabled
        }
      }
      func testFailingTestProcessInfo_isMacCatalystApp() {
        XCTExpectFailure {
          let _ = processInfo.isMacCatalystApp
        }
      }
      func testFailingTestProcessInfo_isiOSAppOnMac() {
        XCTExpectFailure {
          let _ = processInfo.isiOSAppOnMac
        }
      }
      #if os(macOS)
        func testFailingTestProcessInfo_userName() {
          XCTExpectFailure {
            let _ = processInfo.userName
          }
        }
        func testFailingTestProcessInfo_fullUserName() {
          XCTExpectFailure {
            let _ = processInfo.fullUserName
          }
        }
        func testFailingTestProcessInfo_automaticTerminationSupportEnabled() {
          XCTExpectFailure {
            let _ = processInfo.automaticTerminationSupportEnabled
          }
        }
      #endif
      func testFailingTestProcessInfo_beginActivity() {
        XCTExpectFailure {
          let _ = processInfo.beginActivity(options: .background, reason: "")
        }
      }
      func testFailingTestProcessInfo_endActivity() {
        XCTExpectFailure {
          let _ = processInfo.endActivity(NSObject())
        }
      }
      func testFailingTestProcessInfo_performActivity() {
        XCTExpectFailure {
          let _ = processInfo.performActivity(options: .background, reason: "", using: { () })
        }
      }
      #if os(iOS)
        func testFailingTestProcessInfo_performExpiringActivity() {
          XCTExpectFailure {
            let _ = processInfo.performExpiringActivity(withReason: "") { _ in () }
          }
        }
      #endif
      #if os(macOS)
        func testFailingTestProcessInfo_disableSuddenTermination() {
          XCTExpectFailure {
            let _ = processInfo.disableSuddenTermination()
          }
        }
        func testFailingTestProcessInfo_enableSuddenTermination() {
          XCTExpectFailure {
            let _ = processInfo.enableSuddenTermination()
          }
        }
        func testFailingTestProcessInfo_disableAutomaticTermination() {
          XCTExpectFailure {
            let _ = processInfo.disableAutomaticTermination("")
          }
        }
        func testFailingTestProcessInfo_enableAutomaticTermination() {
          XCTExpectFailure {
            let _ = processInfo.enableAutomaticTermination("")
          }
        }
      #endif
    #endif
  }
#endif

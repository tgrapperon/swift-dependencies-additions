import Dependencies
import Foundation
import XCTestDynamicOverlay

// TODO: Convert to closures with a better umplemented.

extension DependencyValues {
  public var processInfo: ProcessInfo.Value {
    get { self[ProcessInfo.Value.self] }
    set { self[ProcessInfo.Value.self] = newValue }
  }
}

extension ProcessInfo.Value: DependencyKey {
  public static var liveValue: ProcessInfo.Value { .init() }

  public static var unimplemented: Self {
    XCTFail(#"Unimplemented: @Dependency(\.processInfo)"#)
    return .init()
  }
}

extension ProcessInfo {
  public struct Value: Sendable {
    public var environment: [String: String]
    public var arguments: [String]
    public var hostName: String
    public var processName: String
    public var processIdentifier: Int32
    public var globallyUniqueString: String
    public var operatingSystemVersionString: String
    public var operatingSystemVersion: OperatingSystemVersion
    public var processorCount: Int
    public var activeProcessorCount: Int
    public var physicalMemory: UInt64
    public var systemUptime: TimeInterval
    public var thermalState: ProcessInfo.ThermalState
    public var isLowPowerModeEnabled: Bool
    public var isMacCatalystApp: Bool
    public var isiOSAppOnMac: Bool

    var _userName: String
    var _fullUserName: String
    var _automaticTerminationSupportEnabled: Bool

    var _beginActivity: @Sendable (ProcessInfo.ActivityOptions, String) -> NSObjectProtocol
    var _endActivity: @Sendable (NSObjectProtocol) -> Void
    var _performActivity:
      @Sendable (ProcessInfo.ActivityOptions, String, @escaping () -> Void) -> Void
    var _performExpiringActivity: @Sendable (String, @escaping @Sendable (Bool) -> Void) -> Void

    var _disableSuddenTermination: @Sendable () -> Void
    var _enableSuddenTermination: @Sendable () -> Void
    var _disableAutomaticTermination: @Sendable (String) -> Void
    var _enableAutomaticTermination: @Sendable (String) -> Void

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var userName: String { _userName }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var fullUserName: String { _fullUserName }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var automaticTerminationSupportEnabled: Bool { _automaticTerminationSupportEnabled }

    public func beginActivity(options: ProcessInfo.ActivityOptions, reason: String)
      -> NSObjectProtocol
    {
      self._beginActivity(options, reason)
    }

    public func endActivity(_ activity: NSObjectProtocol) {
      self._endActivity(activity)
    }

    public func performActivity(
      options: ProcessInfo.ActivityOptions, reason: String, using block: @escaping () -> Void
    ) {
      self._performActivity(options, reason, block)
    }

    @available(macOS, unavailable)
    public func performExpiringActivity(
      withReason reason: String, using block: @escaping @Sendable (Bool) -> Void
    ) {
      self._performExpiringActivity(reason, block)
    }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func disableSuddenTermination() {
      self._disableSuddenTermination()
    }
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func enableSuddenTermination() {
      self._enableSuddenTermination()
    }
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func disableAutomaticTermination(_ reason: String) {
      self._disableAutomaticTermination(reason)
    }
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func enableAutomaticTermination(_ reason: String) {
      self._enableAutomaticTermination(reason)
    }

    public func isOperatingSystemAtLeast(_ version: OperatingSystemVersion) -> Bool {
      if operatingSystemVersion.majorVersion == version.majorVersion {
        if operatingSystemVersion.minorVersion == version.minorVersion {
          return operatingSystemVersion.patchVersion >= version.patchVersion
        } else {
          return operatingSystemVersion.minorVersion > version.minorVersion
        }
      } else {
        return operatingSystemVersion.majorVersion > version.majorVersion
      }
    }

    init(
      environment: @autoclosure () -> [String: String] = {
        ProcessInfo.processInfo.environment
      }(),
      arguments: @autoclosure () -> [String] = {
        ProcessInfo.processInfo.arguments
      }(),
      hostName: @autoclosure () -> String = {
        ProcessInfo.processInfo.hostName
      }(),
      processName: @autoclosure () -> String = {
        ProcessInfo.processInfo.processName
      }(),
      processIdentifier: @autoclosure () -> Int32 = {
        ProcessInfo.processInfo.processIdentifier
      }(),
      globallyUniqueString: @autoclosure () -> String = {
        ProcessInfo.processInfo.globallyUniqueString
      }(),
      operatingSystemVersionString: @autoclosure () -> String = {
        ProcessInfo.processInfo.operatingSystemVersionString
      }(),
      operatingSystemVersion: @autoclosure () -> OperatingSystemVersion = {
        ProcessInfo.processInfo.operatingSystemVersion
      }(),
      processorCount: @autoclosure () -> Int = {
        ProcessInfo.processInfo.processorCount
      }(),
      activeProcessorCount: @autoclosure () -> Int = {
        ProcessInfo.processInfo.activeProcessorCount
      }(),
      physicalMemory: @autoclosure () -> UInt64 = {
        ProcessInfo.processInfo.physicalMemory
      }(),
      systemUptime: @autoclosure () -> TimeInterval = {
        ProcessInfo.processInfo.systemUptime
      }(),
      thermalState: @autoclosure () -> ProcessInfo.ThermalState = {
        ProcessInfo.processInfo.thermalState
      }(),
      isLowPowerModeEnabled: @autoclosure () -> Bool = {
        if #available(macOS 12.0, *) {
          return ProcessInfo.processInfo.isLowPowerModeEnabled
        } else {
          return false
        }
      }(),
      isMacCatalystApp: @autoclosure () -> Bool = {
        ProcessInfo.processInfo.isMacCatalystApp
      }(),
      isiOSAppOnMac: @autoclosure () -> Bool = {
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
          return ProcessInfo.processInfo.isiOSAppOnMac
        } else {
          return false
        }
      }(),
      beginActivity: @escaping @Sendable (ProcessInfo.ActivityOptions, String) -> NSObjectProtocol =
        {
          ProcessInfo.processInfo.beginActivity(options: $0, reason: $1)
        },
      endActivity: @escaping @Sendable (NSObjectProtocol) -> Void = {
        ProcessInfo.processInfo.endActivity($0)
      },
      performActivity: @escaping @Sendable (
        ProcessInfo.ActivityOptions, String, @escaping () -> Void
      ) ->
        Void = {
          ProcessInfo.processInfo.performActivity(options: $0, reason: $1, using: $2)
        },
      performExpiringActivity: @escaping @Sendable (String, @escaping @Sendable (Bool) -> Void) ->
        Void = { reason, block in
          #if os(iOS) || os(tvOS) || os(watchOS)
            return ProcessInfo.processInfo.performExpiringActivity(withReason: reason, using: block)
          #endif
        },
      userName: @autoclosure () -> String = {
        #if os(macOS)
          ProcessInfo.processInfo.userName
        #else
          return ""
        #endif
      }(),
      fullUserName: @autoclosure () -> String = {
        #if os(macOS)
          ProcessInfo.processInfo.fullUserName
        #else
          return ""
        #endif
      }(),
      automaticTerminationSupportEnabled: @autoclosure () -> Bool = {
        #if os(macOS)
          ProcessInfo.processInfo.automaticTerminationSupportEnabled
        #else
          return false
        #endif
      }(),
      disableSuddenTermination: @escaping @Sendable () -> Void = {
        #if os(macOS)
          ProcessInfo.processInfo.disableSuddenTermination()
        #endif
      },
      enableSuddenTermination: @escaping @Sendable () -> Void = {
        #if os(macOS)
          ProcessInfo.processInfo.enableSuddenTermination()
        #endif
      },
      disableAutomaticTermination: @escaping @Sendable (String) -> Void = {
        #if os(macOS)
          ProcessInfo.processInfo.disableAutomaticTermination($0)
        #endif
      },
      enableAutomaticTermination: @escaping @Sendable (String) -> Void = {
        #if os(macOS)
          ProcessInfo.processInfo.enableAutomaticTermination($0)
        #endif
      }
    ) {
      self.environment = environment()
      self.arguments = arguments()
      self.hostName = hostName()
      self.processName = processName()
      self.processIdentifier = processIdentifier()
      self.globallyUniqueString = globallyUniqueString()
      self.operatingSystemVersionString = operatingSystemVersionString()
      self.operatingSystemVersion = operatingSystemVersion()
      self.processorCount = processorCount()
      self.activeProcessorCount = activeProcessorCount()
      self.physicalMemory = physicalMemory()
      self.systemUptime = systemUptime()
      self.thermalState = thermalState()
      self.isLowPowerModeEnabled = isLowPowerModeEnabled()
      self.isMacCatalystApp = isMacCatalystApp()
      self.isiOSAppOnMac = isiOSAppOnMac()

      self._beginActivity = beginActivity
      self._endActivity = endActivity
      self._performActivity = performActivity
      self._performExpiringActivity = performExpiringActivity

      self._userName = userName()
      self._fullUserName = fullUserName()
      self._automaticTerminationSupportEnabled = automaticTerminationSupportEnabled()

      self._disableSuddenTermination = disableSuddenTermination
      self._enableSuddenTermination = enableSuddenTermination
      self._disableAutomaticTermination = disableAutomaticTermination
      self._enableAutomaticTermination = enableAutomaticTermination
    }
  }
}

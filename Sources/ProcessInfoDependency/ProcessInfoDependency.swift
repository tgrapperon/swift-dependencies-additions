import Dependencies
import DependenciesAdditions
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  /// An abstraction of `ProcessInfo`, a collection of information about the current process.
  public var processInfo: ProcessInfo.Value {
    get { self[ProcessInfo.Value.self] }
    set { self[ProcessInfo.Value.self] = newValue }
  }
}

extension ProcessInfo.Value: DependencyKey {
  public static var liveValue: ProcessInfo.Value { .processInfo }
  public static var testValue: ProcessInfo.Value { .unimplemented }
}

extension ProcessInfo {
  /// A collection of information about the current process.
  public struct Value: Sendable {
    /// The variable names (keys) and their values in the environment from which the process was launched.
    @ROLP public var environment: [String: String]

    /// Array of strings with the command-line arguments for the process.
    @ROLP public var arguments: [String]

    /// The name of the host computer on which the process is executing.
    @ROLP public var hostName: String

    /// The name of the process.
    @ROLP public var processName: String

    /// The identifier of the process (often called process ID).
    @ROLP public var processIdentifier: Int32

    /// Global unique identifier for the process.
    @ROLP public var globallyUniqueString: String

    /// A string containing the version of the operating system on which the process is executing.
    @ROLP public var operatingSystemVersionString: String

    /// The version of the operating system on which the process is executing.
    @ROLP public var operatingSystemVersion: OperatingSystemVersion

    /// The number of processing cores available on the computer.
    @ROLP public var processorCount: Int

    /// The number of active processing cores available on the computer.
    @ROLP public var activeProcessorCount: Int

    /// The amount of physical memory on the computer in bytes.
    @ROLP public var physicalMemory: UInt64

    /// The amount of time the system has been awake since the last time it was restarted.
    @ROLP public var systemUptime: TimeInterval

    /// The current thermal state of the system.
    @ROLP public var thermalState: ProcessInfo.ThermalState

    /// A Boolean value that indicates the current state of Low Power Mode.
    @ROLP public var isLowPowerModeEnabled: Bool

    /// A Boolean value that indicates whether the process originated as an iOS app and runs on
    /// macOS.
    @ROLP public var isMacCatalystApp: Bool

    /// A Boolean value that indicates whether the process is an iPhone or iPad app running on a
    ///  Mac.
    @ROLP public var isiOSAppOnMac: Bool

    @ROLP private var _userName: String
    @ROLP private var _fullUserName: String
    @ROLP private var _automaticTerminationSupportEnabled: Bool

    private var _beginActivity: @Sendable (ProcessInfo.ActivityOptions, String) -> NSObjectProtocol
    private var _endActivity: @Sendable (NSObjectProtocol) -> Void
    private var _performActivity:
      @Sendable (ProcessInfo.ActivityOptions, String, @escaping @Sendable () -> Void) -> Void
    private var _performExpiringActivity:
      @Sendable (String, @escaping @Sendable (Bool) -> Void) -> Void
    private var _disableSuddenTermination: @Sendable () -> Void
    private var _enableSuddenTermination: @Sendable () -> Void
    private var _disableAutomaticTermination: @Sendable (String) -> Void
    private var _enableAutomaticTermination: @Sendable (String) -> Void
    private var _isOperatingSystemAtLeast: @Sendable (OperatingSystemVersion) -> Bool

    init(
      environment: @escaping @autoclosure () -> [String: String],
      arguments: @escaping @autoclosure () -> [String],
      hostName: @escaping @autoclosure () -> String,
      processName: @escaping @autoclosure () -> String,
      processIdentifier: @escaping @autoclosure () -> Int32,
      globallyUniqueString: @escaping @autoclosure () -> String,
      operatingSystemVersionString: @escaping @autoclosure () -> String,
      operatingSystemVersion: @escaping @autoclosure () -> OperatingSystemVersion,
      processorCount: @escaping @autoclosure () -> Int,
      activeProcessorCount: @escaping @autoclosure () -> Int,
      physicalMemory: @escaping @autoclosure () -> UInt64,
      systemUptime: @escaping @autoclosure () -> TimeInterval,
      thermalState: @escaping @autoclosure () -> ProcessInfo.ThermalState,
      isLowPowerModeEnabled: @escaping @autoclosure () -> Bool,
      isMacCatalystApp: @escaping @autoclosure () -> Bool,
      isiOSAppOnMac: @escaping @autoclosure () -> Bool,
      userName: @escaping @autoclosure () -> String,
      fullUserName: @escaping @autoclosure () -> String,
      automaticTerminationSupportEnabled: @escaping @autoclosure () -> Bool,
      isOperatingSystemAtLeast: @escaping @Sendable (OperatingSystemVersion) -> Bool,
      beginActivity: @escaping @Sendable (ProcessInfo.ActivityOptions, String) -> NSObjectProtocol,
      endActivity: @escaping @Sendable (NSObjectProtocol) -> Void,
      performActivity: @escaping @Sendable (
        ProcessInfo.ActivityOptions, String, @escaping @Sendable () -> Void
      ) -> Void,
      performExpiringActivity: @escaping @Sendable (String, @escaping @Sendable (Bool) -> Void) ->
        Void,
      disableSuddenTermination: @escaping @Sendable () -> Void,
      enableSuddenTermination: @escaping @Sendable () -> Void,
      disableAutomaticTermination: @escaping @Sendable (String) -> Void,
      enableAutomaticTermination: @escaping @Sendable (String) -> Void
    ) {
      self._environment = .init(environment)
      self._arguments = .init(arguments)
      self._hostName = .init(hostName)
      self._processName = .init(processName)
      self._processIdentifier = .init(processIdentifier)
      self._globallyUniqueString = .init(globallyUniqueString)
      self._operatingSystemVersionString = .init(operatingSystemVersionString)
      self._operatingSystemVersion = .init(operatingSystemVersion)
      self._processorCount = .init(processorCount)
      self._activeProcessorCount = .init(activeProcessorCount)
      self._physicalMemory = .init(physicalMemory)
      self._systemUptime = .init(systemUptime)
      self._thermalState = .init(thermalState)
      self._isLowPowerModeEnabled = .init(isLowPowerModeEnabled)
      self._isMacCatalystApp = .init(isMacCatalystApp)
      self._isiOSAppOnMac = .init(isiOSAppOnMac)
      self.__userName = .init(userName)
      self.__fullUserName = .init(fullUserName)
      self.__automaticTerminationSupportEnabled = .init(automaticTerminationSupportEnabled)
      self._isOperatingSystemAtLeast = isOperatingSystemAtLeast
      self._beginActivity = beginActivity
      self._endActivity = endActivity
      self._performActivity = performActivity
      self._performExpiringActivity = performExpiringActivity
      self._disableSuddenTermination = disableSuddenTermination
      self._enableSuddenTermination = enableSuddenTermination
      self._disableAutomaticTermination = disableAutomaticTermination
      self._enableAutomaticTermination = enableAutomaticTermination
    }
  }
}

extension ProcessInfo.Value {
  /// Returns the account name of the current user.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var userName: String { _userName }

  /// Returns the full name of the current user.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var fullUserName: String { _fullUserName }

  /// A Boolean value indicating whether the app supports automatic termination.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var automaticTerminationSupportEnabled: Bool { _automaticTerminationSupportEnabled }

  /// Begin an activity using the given options and reason.
  public func beginActivity(options: ProcessInfo.ActivityOptions, reason: String)
    -> NSObjectProtocol
  {
    self._beginActivity(options, reason)
  }

  /// Ends the given activity.
  public func endActivity(_ activity: NSObjectProtocol) {
    self._endActivity(activity)
  }

  /// Synchronously perform an activity defined by a given block using the given options.
  public func performActivity(
    options: ProcessInfo.ActivityOptions, reason: String,
    using block: @escaping @Sendable () -> Void
  ) {
    self._performActivity(options, reason, block)
  }

  /// Performs the specified block asynchronously and notifies you if the process is about to be
  /// suspended.
  @available(macOS, unavailable)
  public func performExpiringActivity(
    withReason reason: String, using block: @escaping @Sendable (Bool) -> Void
  ) {
    self._performExpiringActivity(reason, block)
  }

  /// Disables the application for quickly killing using sudden termination.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public func disableSuddenTermination() {
    self._disableSuddenTermination()
  }

  /// Enables the application for quick killing using sudden termination.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public func enableSuddenTermination() {
    self._enableSuddenTermination()
  }

  /// Disables automatic termination for the application.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public func disableAutomaticTermination(_ reason: String) {
    self._disableAutomaticTermination(reason)
  }

  /// Enables automatic termination for the application.
  @available(iOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public func enableAutomaticTermination(_ reason: String) {
    self._enableAutomaticTermination(reason)
  }

  /// Returns a Boolean value indicating whether the version of the operating system on which the
  ///  process is executing is the same or later than the given version.
  public func isOperatingSystemAtLeast(_ version: OperatingSystemVersion) -> Bool {
    self._isOperatingSystemAtLeast(version)
  }
}

extension ProcessInfo.Value {
  static var processInfo: ProcessInfo.Value {
    return .init(
      environment: ProcessInfo.processInfo.environment,
      arguments: ProcessInfo.processInfo.arguments,
      hostName: ProcessInfo.processInfo.hostName,
      processName: ProcessInfo.processInfo.processName,
      processIdentifier: ProcessInfo.processInfo.processIdentifier,
      globallyUniqueString: ProcessInfo.processInfo.globallyUniqueString,
      operatingSystemVersionString: ProcessInfo.processInfo.operatingSystemVersionString,
      operatingSystemVersion: ProcessInfo.processInfo.operatingSystemVersion,
      processorCount: ProcessInfo.processInfo.processorCount,
      activeProcessorCount: ProcessInfo.processInfo.activeProcessorCount,
      physicalMemory: ProcessInfo.processInfo.physicalMemory,
      systemUptime: ProcessInfo.processInfo.systemUptime,
      thermalState: ProcessInfo.processInfo.thermalState,
      isLowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled,
      isMacCatalystApp: ProcessInfo.processInfo.isMacCatalystApp,
      isiOSAppOnMac: {
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
          return ProcessInfo.processInfo.isiOSAppOnMac
        } else {
          return false
        }
      }(),
      userName: {
        #if os(macOS)
        ProcessInfo.processInfo.userName
        #else
          return ""
        #endif
      }(),
      fullUserName: {
        #if os(macOS)
        ProcessInfo.processInfo.fullUserName
        #else
          return ""
        #endif
      }(),
      automaticTerminationSupportEnabled: {
        #if os(macOS)
        ProcessInfo.processInfo.automaticTerminationSupportEnabled
        #else
          return false
        #endif
      }(),
      isOperatingSystemAtLeast: {
        ProcessInfo.processInfo.isOperatingSystemAtLeast($0)
      },
      beginActivity: {
        ProcessInfo.processInfo.beginActivity(options: $0, reason: $1)
      },
      endActivity: {
        ProcessInfo.processInfo.endActivity($0)
      },
      performActivity: {
        ProcessInfo.processInfo.performActivity(options: $0, reason: $1, using: $2)
      },
      performExpiringActivity: { reason, block in
        #if os(iOS) || os(tvOS) || os(watchOS)
        ProcessInfo.processInfo.performExpiringActivity(withReason: reason, using: block)
        #endif
      },
      disableSuddenTermination: {
        #if os(macOS)
        ProcessInfo.processInfo.disableSuddenTermination()
        #endif
      },
      enableSuddenTermination: {
        #if os(macOS)
        ProcessInfo.processInfo.enableSuddenTermination()
        #endif
      },
      disableAutomaticTermination: {
        #if os(macOS)
        ProcessInfo.processInfo.disableAutomaticTermination($0)
        #endif
      },
      enableAutomaticTermination: {
        #if os(macOS)
        ProcessInfo.processInfo.enableAutomaticTermination($0)
        #endif
      })
  }
}

extension ProcessInfo.Value {
  static var unimplemented: Self {
    .init(
      environment: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.environment)"#),
      arguments: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.arguments)"#),
      hostName: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.hostName)"#),
      processName: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.processName)"#),
      processIdentifier: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.processIdentifier)"#),
      globallyUniqueString: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.globallyUniqueString)"#),
      operatingSystemVersionString: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.operatingSystemVersionString)"#),
      operatingSystemVersion: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.operatingSystemVersion)"#,
        placeholder: .init(majorVersion: 0, minorVersion: 0, patchVersion: 0)),
      processorCount: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.processorCount)"#),
      activeProcessorCount: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.activeProcessorCount)"#),
      physicalMemory: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.physicalMemory)"#),
      systemUptime: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.systemUptime)"#),
      thermalState: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.thermalState)"#),
      isLowPowerModeEnabled: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.isLowPowerModeEnabled)"#),
      isMacCatalystApp: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.isMacCatalystApp)"#),
      isiOSAppOnMac: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.isiOSAppOnMac)"#),
      userName: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.userName)"#),
      fullUserName: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.fullUserName)"#),
      automaticTerminationSupportEnabled: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.automaticTerminationSupportEnabled)"#),
      isOperatingSystemAtLeast: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.isOperatingSystemAtLeast)"#),
      beginActivity: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.beginActivity)"#, placeholder: NSObject()),
      endActivity: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.endActivity)"#),
      performActivity: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.performActivity)"#),
      performExpiringActivity: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.performExpiringActivity)"#),
      disableSuddenTermination: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.disableSuddenTermination)"#),
      enableSuddenTermination: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.enableSuddenTermination)"#),
      disableAutomaticTermination: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.disableAutomaticTermination)"#),
      enableAutomaticTermination: XCTestDynamicOverlay.unimplemented(
        #"@Dependency(\.processInfo.enableAutomaticTermination)"#))
  }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
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
    public static var previewValue: ProcessInfo.Value { .processInfo }
  }

  extension ProcessInfo {
    /// A collection of information about the current process.
    public struct Value: Sendable, ConfigurableProxy {
      public struct Implementation: Sendable {
        @ReadOnlyProxy public var environment: [String: String]
        @ReadOnlyProxy public var arguments: [String]
        @ReadOnlyProxy public var hostName: String
        @ReadOnlyProxy public var processName: String
        @ReadOnlyProxy public var processIdentifier: Int32
        @ReadOnlyProxy public var globallyUniqueString: String
        @ReadOnlyProxy public var operatingSystemVersionString: String
        @ReadOnlyProxy public var operatingSystemVersion: OperatingSystemVersion
        @ReadOnlyProxy public var processorCount: Int
        @ReadOnlyProxy public var activeProcessorCount: Int
        @ReadOnlyProxy public var physicalMemory: UInt64
        @ReadOnlyProxy public var systemUptime: TimeInterval
        @ReadOnlyProxy public var thermalState: ProcessInfo.ThermalState
        @ReadOnlyProxy public var isLowPowerModeEnabled: Bool
        @ReadOnlyProxy public var isMacCatalystApp: Bool
        @ReadOnlyProxy public var isiOSAppOnMac: Bool
        @ReadOnlyProxy public var userName: String
        @ReadOnlyProxy public var fullUserName: String
        @ReadOnlyProxy public var automaticTerminationSupportEnabled: Bool
        @FunctionProxy public var beginActivity:
          @Sendable (ProcessInfo.ActivityOptions, String) -> NSObjectProtocol
        @FunctionProxy public var endActivity: @Sendable (NSObjectProtocol) -> Void
        @FunctionProxy public var performActivity:
          @Sendable (ProcessInfo.ActivityOptions, String, @escaping @Sendable () -> Void) -> Void
        @FunctionProxy public var performExpiringActivity:
          @Sendable (String, @escaping @Sendable (Bool) -> Void) -> Void
        @FunctionProxy public var disableSuddenTermination: @Sendable () -> Void
        @FunctionProxy public var enableSuddenTermination: @Sendable () -> Void
        @FunctionProxy public var disableAutomaticTermination: @Sendable (String) -> Void
        @FunctionProxy public var enableAutomaticTermination: @Sendable (String) -> Void
        @FunctionProxy public var isOperatingSystemAtLeast:
          @Sendable (OperatingSystemVersion) -> Bool
      }

      @_spi(Internals) public var _implementation: Implementation

    }
  }

  extension ProcessInfo.Value {
    /// The variable names (keys) and their values in the environment from which the process was
    /// launched.
    public var environment: [String: String] {
      self._implementation.environment
    }

    /// Array of strings with the command-line arguments for the process.
    public var arguments: [String] {
      self._implementation.arguments
    }

    /// The name of the host computer on which the process is executing.
    public var hostName: String {
      self._implementation.hostName
    }

    /// The name of the process.
    public var processName: String {
      self._implementation.processName
    }

    /// The identifier of the process (often called process ID).
    public var processIdentifier: Int32 {
      self._implementation.processIdentifier
    }

    /// Global unique identifier for the process.
    public var globallyUniqueString: String {
      self._implementation.globallyUniqueString
    }

    /// A string containing the version of the operating system on which the process is executing.
    public var operatingSystemVersionString: String {
      self._implementation.operatingSystemVersionString
    }

    /// The version of the operating system on which the process is executing.
    public var operatingSystemVersion: OperatingSystemVersion {
      self._implementation.operatingSystemVersion
    }

    /// The number of processing cores available on the computer.
    public var processorCount: Int {
      self._implementation.processorCount
    }

    /// The number of active processing cores available on the computer.
    public var activeProcessorCount: Int {
      self._implementation.activeProcessorCount
    }

    /// The amount of physical memory on the computer in bytes.
    public var physicalMemory: UInt64 {
      self._implementation.physicalMemory
    }

    /// The amount of time the system has been awake since the last time it was restarted.
    public var systemUptime: TimeInterval {
      self._implementation.systemUptime
    }

    /// The current thermal state of the system.
    public var thermalState: ProcessInfo.ThermalState {
      self._implementation.thermalState
    }

    /// A Boolean value that indicates the current state of Low Power Mode.
    public var isLowPowerModeEnabled: Bool {
      self._implementation.isLowPowerModeEnabled
    }

    /// A Boolean value that indicates whether the process originated as an iOS app and runs on
    /// macOS.
    public var isMacCatalystApp: Bool {
      self._implementation.isMacCatalystApp
    }

    /// A Boolean value that indicates whether the process is an iPhone or iPad app running on a
    ///  Mac.
    public var isiOSAppOnMac: Bool {
      self._implementation.isiOSAppOnMac
    }
    /// Returns the account name of the current user.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var userName: String { self._implementation.userName }

    /// Returns the full name of the current user.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var fullUserName: String { self._implementation.fullUserName }

    /// A Boolean value indicating whether the app supports automatic termination.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var automaticTerminationSupportEnabled: Bool {
      self._implementation.automaticTerminationSupportEnabled
    }

    /// Begin an activity using the given options and reason.
    public func beginActivity(options: ProcessInfo.ActivityOptions, reason: String)
      -> NSObjectProtocol
    {
      self._implementation.beginActivity(options, reason)
    }

    /// Ends the given activity.
    public func endActivity(_ activity: NSObjectProtocol) {
      self._implementation.endActivity(activity)
    }

    /// Synchronously perform an activity defined by a given block using the given options.
    public func performActivity(
      options: ProcessInfo.ActivityOptions, reason: String,
      using block: @escaping @Sendable () -> Void
    ) {
      self._implementation.performActivity(options, reason, block)
    }

    /// Performs the specified block asynchronously and notifies you if the process is about to be
    /// suspended.
    @available(macOS, unavailable)
    public func performExpiringActivity(
      withReason reason: String, using block: @escaping @Sendable (Bool) -> Void
    ) {
      self._implementation.performExpiringActivity(reason, block)
    }

    /// Disables the application for quickly killing using sudden termination.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func disableSuddenTermination() {
      self._implementation.disableSuddenTermination()
    }

    /// Enables the application for quick killing using sudden termination.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func enableSuddenTermination() {
      self._implementation.enableSuddenTermination()
    }

    /// Disables automatic termination for the application.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func disableAutomaticTermination(_ reason: String) {
      self._implementation.disableAutomaticTermination(reason)
    }

    /// Enables automatic termination for the application.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func enableAutomaticTermination(_ reason: String) {
      self._implementation.enableAutomaticTermination(reason)
    }

    /// Returns a Boolean value indicating whether the version of the operating system on which the
    ///  process is executing is the same or later than the given version.
    public func isOperatingSystemAtLeast(_ version: OperatingSystemVersion) -> Bool {
      self._implementation.isOperatingSystemAtLeast(version)
    }
  }

  extension ProcessInfo.Value {
    public static var processInfo: ProcessInfo.Value {
      .init(
        _implementation: .init(
          environment: .init(ProcessInfo.processInfo.environment),
          arguments: .init(ProcessInfo.processInfo.arguments),
          hostName: .init(ProcessInfo.processInfo.hostName),
          processName: .init(ProcessInfo.processInfo.processName),
          processIdentifier: .init(ProcessInfo.processInfo.processIdentifier),
          globallyUniqueString: .init(ProcessInfo.processInfo.globallyUniqueString),
          operatingSystemVersionString: .init(ProcessInfo.processInfo.operatingSystemVersionString),
          operatingSystemVersion: .init(ProcessInfo.processInfo.operatingSystemVersion),
          processorCount: .init(ProcessInfo.processInfo.processorCount),
          activeProcessorCount: .init(ProcessInfo.processInfo.activeProcessorCount),
          physicalMemory: .init(ProcessInfo.processInfo.physicalMemory),
          systemUptime: .init(ProcessInfo.processInfo.systemUptime),
          thermalState: .init(ProcessInfo.processInfo.thermalState),
          isLowPowerModeEnabled: .init {
            if #available(macOS 12.0, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
              return ProcessInfo.processInfo.isLowPowerModeEnabled
            } else {
              return false
            }
          },
          isMacCatalystApp: .init(ProcessInfo.processInfo.isMacCatalystApp),
          isiOSAppOnMac: .init {
            if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
              return ProcessInfo.processInfo.isiOSAppOnMac
            } else {
              return false
            }
          },
          userName: .init {
            #if os(macOS)
              ProcessInfo.processInfo.userName
            #else
              return ""
            #endif
          },
          fullUserName: .init {
            #if os(macOS)
              ProcessInfo.processInfo.fullUserName
            #else
              return ""
            #endif
          },
          automaticTerminationSupportEnabled: .init {
            #if os(macOS)
              ProcessInfo.processInfo.automaticTerminationSupportEnabled
            #else
              return false
            #endif
          },
          beginActivity: .init {
            ProcessInfo.processInfo.beginActivity(options: $0, reason: $1)
          },
          endActivity: .init { ProcessInfo.processInfo.endActivity($0) },
          performActivity: .init {
            ProcessInfo.processInfo.performActivity(options: $0, reason: $1, using: $2)
          },
          performExpiringActivity: .init { reason, block in
            #if os(iOS) || os(tvOS) || os(watchOS)
              ProcessInfo.processInfo.performExpiringActivity(withReason: reason, using: block)
            #endif
          },
          disableSuddenTermination: .init {
            #if os(macOS)
              ProcessInfo.processInfo.disableSuddenTermination()
            #else
              ()
            #endif
          },
          enableSuddenTermination: .init {
            #if os(macOS)
              ProcessInfo.processInfo.enableSuddenTermination()
            #else
              ()
            #endif
          },
          disableAutomaticTermination: .init {
            #if os(macOS)
              ProcessInfo.processInfo.disableAutomaticTermination($0)
            #else
              ()
            #endif
          },
          enableAutomaticTermination: .init {
            #if os(macOS)
              ProcessInfo.processInfo.enableAutomaticTermination($0)
            #else
              ()
            #endif
          },
          isOperatingSystemAtLeast: .init {
            ProcessInfo.processInfo.isOperatingSystemAtLeast($0)
          }
        )
      )
    }
  }

  extension ProcessInfo.Value {
    public static var unimplemented: Self {
      ProcessInfo.Value(
        _implementation: .init(
          environment: .unimplemented(
            #"@Dependency(\.processInfo.environment)"#),
          arguments: .unimplemented(
            #"@Dependency(\.processInfo.arguments)"#),
          hostName: .unimplemented(
            #"@Dependency(\.processInfo.hostName)"#),
          processName: .unimplemented(
            #"@Dependency(\.processInfo.processName)"#),
          processIdentifier: .unimplemented(
            #"@Dependency(\.processInfo.processIdentifier)"#),
          globallyUniqueString: .unimplemented(
            #"@Dependency(\.processInfo.globallyUniqueString)"#),
          operatingSystemVersionString: .unimplemented(
            #"@Dependency(\.processInfo.operatingSystemVersionString)"#),
          operatingSystemVersion: .unimplemented(
            #"@Dependency(\.processInfo.operatingSystemVersion)"#,
            placeholder: .init(majorVersion: 0, minorVersion: 0, patchVersion: 1)),
          processorCount: .unimplemented(
            #"@Dependency(\.processInfo.processorCount)"#),
          activeProcessorCount: .unimplemented(
            #"@Dependency(\.processInfo.activeProcessorCount)"#),
          physicalMemory: .unimplemented(
            #"@Dependency(\.processInfo.physicalMemory)"#),
          systemUptime: .unimplemented(
            #"@Dependency(\.processInfo.systemUptime)"#),
          thermalState: .unimplemented(
            #"@Dependency(\.processInfo.thermalState)"#,
            placeholder: .critical),
          isLowPowerModeEnabled: .unimplemented(
            #"@Dependency(\.processInfo.isLowPowerModeEnabled)"#),
          isMacCatalystApp: .unimplemented(
            #"@Dependency(\.processInfo.isMacCatalystApp)"#),
          isiOSAppOnMac: .unimplemented(
            #"@Dependency(\.processInfo.isiOSAppOnMac)"#),
          userName: .unimplemented(
            #"@Dependency(\.processInfo.userName)"#),
          fullUserName: .unimplemented(
            #"@Dependency(\.processInfo.fullUserName)"#),
          automaticTerminationSupportEnabled: .unimplemented(
            #"@Dependency(\.processInfo.automaticTerminationSupportEnabled)"#),
          beginActivity: .unimplemented(
            #"@Dependency(\.processInfo.beginActivity)"#,
            placeholder: { _, _ in NSObject() }),
          endActivity: .unimplemented(
            #"@Dependency(\.processInfo.endActivity)"#),
          performActivity:
            .unimplemented(
              #"@Dependency(\.processInfo.performActivity)"#),
          performExpiringActivity: .unimplemented(
            #"@Dependency(\.processInfo.performExpiringActivity)"#),
          disableSuddenTermination: .unimplemented(
            #"@Dependency(\.processInfo.disableSuddenTermination)"#),
          enableSuddenTermination: .unimplemented(
            #"@Dependency(\.processInfo.enableSuddenTermination)"#),
          disableAutomaticTermination: .unimplemented(
            #"@Dependency(\.processInfo.disableAutomaticTermination)"#),
          enableAutomaticTermination: .unimplemented(
            #"@Dependency(\.processInfo.enableAutomaticTermination)"#),
          isOperatingSystemAtLeast: .unimplemented(
            #"@Dependency(\.processInfo.isOperatingSystemAtLeast)"#)
        )
      )
    }
  }
#endif

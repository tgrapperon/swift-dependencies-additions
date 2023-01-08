import Dependencies
@_spi(Internals) import DependenciesAdditions
import XCTestDynamicOverlay

#if os(watchOS)
  import WatchKit.WKInterfaceDevice

  extension DependencyValues {
    /// An object that provides information about the user’s Apple Watch.
    public var device: Device {
      get { self[DeviceKey.self] }
      set { self[DeviceKey.self] = newValue }
    }
  }

  enum DeviceKey: DependencyKey {
    public static var liveValue: Device {
      .current
    }
    public static var testValue: Device {
      .unimplemented
    }
    static var previewValue: Device {
      .current
    }
  }

  /// An object that provides information about the user’s Apple Watch.
  public struct Device: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      @FunctionProxy public var name: String
      @FunctionProxy public var model: String
      @FunctionProxy public var localizedModel: String
      @FunctionProxy public var systemName: String
      @FunctionProxy public var systemVersion: String
      @FunctionProxy public var identifierForVendor: UUID?
      @FunctionProxy public var screenBounds: CGRect
      @FunctionProxy public var screenScale: CGFloat
      @FunctionProxy public var preferredContentSizeCategory: String
      @FunctionProxy public var layoutDirection: WKInterfaceLayoutDirection
      @FunctionProxy public var wristLocation: WKInterfaceDeviceWristLocation
      @FunctionProxy public var crownOrientation: WKInterfaceDeviceCrownOrientation
      @ReadWriteProxy public var isBatteryMonitoringEnabled: Bool
      @FunctionProxy public var batteryState: WKInterfaceDeviceBatteryState
      @FunctionProxy public var batteryLevel: Float
      @FunctionProxy public var waterResistanceRating: WKWaterResistanceRating
      @FunctionProxy public var isWaterLockEnabled: Bool
      @FunctionProxy public var supportsAudioStreaming: Bool
      @FunctionProxy public var play: @Sendable (WKHapticType) -> Void
      @FunctionProxy public var enableWaterLock: @Sendable () -> Void
    }

    @_spi(Internals) public var _implementation: Implementation

    /// The name assigned to the underlying device.
    public var name: String {
      self._implementation.name
    }
    /// The model information for the device.
    public var model: String {
      self._implementation.model
    }
    /// The localized version of the model information.
    public var localizedModel: String {
      self._implementation.localizedModel
    }
    /// The name of the operating system.
    public var systemName: String {
      self._implementation.systemName
    }
    /// An alphanumeric string that uniquely identifies a device to the app’s vendor.
    public var systemVersion: String {
      self._implementation.systemVersion
    }
    /// An alphanumeric string that uniquely identifies a device to the app’s vendor.
    public var identifierForVendor: UUID? {
      self._implementation.identifierForVendor
    }
    ///The bounding rectangle of the screen.
    public var screenBounds: CGRect {
      self._implementation.screenBounds
    }
    /// The number of pixels per point for the current screen.
    public var screenScale: CGFloat {
      self._implementation.screenScale
    }
    /// The preferred font-sizing option.
    public var preferredContentSizeCategory: String {
      self._implementation.preferredContentSizeCategory
    }
    /// The layout direction of the user interface.
    public var layoutDirection: WKInterfaceLayoutDirection {
      self._implementation.layoutDirection
    }
    /// The wrist on which the user wears the Apple Watch.
    public var wristLocation: WKInterfaceDeviceWristLocation {
      self._implementation.wristLocation
    }
    /// The side on which the crown is positioned.
    public var crownOrientation: WKInterfaceDeviceCrownOrientation {
      self._implementation.crownOrientation
    }
    /// A Boolean value that determines whether the app can monitor the device's battery.
    public var isBatteryMonitoringEnabled: Bool {
      get { self._implementation.isBatteryMonitoringEnabled }
      nonmutating set { self._implementation.isBatteryMonitoringEnabled = newValue }
    }
    /// The device's battery state.
    public var batteryState: WKInterfaceDeviceBatteryState {
      self._implementation.batteryState
    }
    /// The battery's current percent charge.
    public var batteryLevel: Float {
      self._implementation.batteryLevel
    }
    /// The Apple Watch water-resistance rating.
    public var waterResistanceRating: WKWaterResistanceRating {
      self._implementation.waterResistanceRating
    }
    /// A Boolean value that indicates whether the water lock is enabled.
    public var isWaterLockEnabled: Bool {
      self._implementation.isWaterLockEnabled
    }
    /// A Boolean value that indicates whether the device supports audio streaming.
    public var supportsAudioStreaming: Bool {
      self._implementation.supportsAudioStreaming
    }
    /// Gives haptic feedback to the user.
    public func play(_ haptic: WKHapticType) {
      self._implementation.play(haptic)
    }
    /// Disables the Apple Watch touch screen to prevent accidental taps while submerged.
    public func enableWaterLock() {
      self._implementation.enableWaterLock()
    }

    init(
      name: @escaping @Sendable @autoclosure () -> String,
      model: @escaping @Sendable @autoclosure () -> String,
      localizedModel: @escaping @Sendable @autoclosure () -> String,
      systemName: @escaping @Sendable @autoclosure () -> String,
      systemVersion: @escaping @Sendable @autoclosure () -> String,
      identifierForVendor: @escaping @Sendable @autoclosure () -> UUID?,
      screenBounds: @escaping @Sendable @autoclosure () -> CGRect,
      screenScale: @escaping @Sendable @autoclosure () -> CGFloat,
      preferredContentSizeCategory: @escaping @Sendable @autoclosure () -> String,
      layoutDirection: @escaping @Sendable @autoclosure () -> WKInterfaceLayoutDirection,
      wristLocation: @escaping @Sendable @autoclosure () -> WKInterfaceDeviceWristLocation,
      crownOrientation: @escaping @Sendable @autoclosure () -> WKInterfaceDeviceCrownOrientation,
      isBatteryMonitoringEnabled: (get: @Sendable () -> Bool, set: @Sendable (Bool) -> Void),
      batteryState: @escaping @Sendable @autoclosure () -> WKInterfaceDeviceBatteryState,
      batteryLevel: @escaping @Sendable @autoclosure () -> Float,
      waterResistanceRating: @escaping @Sendable @autoclosure () -> WKWaterResistanceRating,
      isWaterLockEnabled: @escaping @Sendable @autoclosure () -> Bool,
      supportsAudioStreaming: @escaping @Sendable @autoclosure () -> Bool,
      play: @escaping @Sendable (WKHapticType) -> Void,
      enableWaterLock: @escaping @Sendable () -> Void
    ) {
      self._implementation = .init(
        name: .init(name),
        model: .init(model),
        localizedModel: .init(localizedModel),
        systemName: .init(systemName),
        systemVersion: .init(systemVersion),
        identifierForVendor: .init(identifierForVendor),
        screenBounds: .init(screenBounds),
        screenScale: .init(screenScale),
        preferredContentSizeCategory: .init(preferredContentSizeCategory),
        layoutDirection: .init(layoutDirection),
        wristLocation: .init(wristLocation),
        crownOrientation: .init(crownOrientation),
        isBatteryMonitoringEnabled: .init(.init(isBatteryMonitoringEnabled)),
        batteryState: .init(batteryState),
        batteryLevel: .init(batteryLevel),
        waterResistanceRating: .init(waterResistanceRating),
        isWaterLockEnabled: .init(isWaterLockEnabled),
        supportsAudioStreaming: .init(supportsAudioStreaming),
        play: .init({ play }),
        enableWaterLock: .init({ enableWaterLock })
      )
    }
  }

  extension Device {
    public static var current: Device {
      .init(
        name: WKInterfaceDevice.current().name,
        model: WKInterfaceDevice.current().model,
        localizedModel: WKInterfaceDevice.current().localizedModel,
        systemName: WKInterfaceDevice.current().systemName,
        systemVersion: WKInterfaceDevice.current().systemVersion,
        identifierForVendor: {
          if #available(watchOS 6.2, *) {
            return WKInterfaceDevice.current().identifierForVendor
          } else {
            // TODO: Add warning
            return nil
          }
        }(),
        screenBounds: WKInterfaceDevice.current().screenBounds,
        screenScale: WKInterfaceDevice.current().screenScale,
        preferredContentSizeCategory: WKInterfaceDevice.current().preferredContentSizeCategory,
        layoutDirection: WKInterfaceDevice.current().layoutDirection,
        wristLocation: WKInterfaceDevice.current().wristLocation,
        crownOrientation: WKInterfaceDevice.current().crownOrientation,
        isBatteryMonitoringEnabled: (
          {
            WKInterfaceDevice.current().isBatteryMonitoringEnabled
          },
          {
            WKInterfaceDevice.current().isBatteryMonitoringEnabled = $0
          }
        ),
        batteryState: WKInterfaceDevice.current().batteryState,
        batteryLevel: WKInterfaceDevice.current().batteryLevel,
        waterResistanceRating: WKInterfaceDevice.current().waterResistanceRating,
        isWaterLockEnabled: {
          if #available(watchOS 6.1, *) {
            return WKInterfaceDevice.current().isWaterLockEnabled
          } else {
            // TODO: Add warning
            return false
          }
        }(),
        supportsAudioStreaming: WKInterfaceDevice.current().supportsAudioStreaming,
        play: { WKInterfaceDevice.current().play($0) },
        enableWaterLock: {
          if #available(watchOS 6.1, *) {
            WKInterfaceDevice.current().enableWaterLock()
          } else {
            // TODO: Add warning
          }
        }
      )
    }
  }

  extension Device {
    public static var unimplemented: Device {
      .init(
        name: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.name)"#),
        model: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.model)"#),
        localizedModel: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.localizedModel)"#),
        systemName: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.systemName)"#),
        systemVersion: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.systemVersion)"#),
        identifierForVendor: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.identifierForVendor)"#, placeholder: nil),
        screenBounds: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.screenBounds)"#, placeholder: .zero),
        screenScale: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.screenScale)"#),
        preferredContentSizeCategory: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.preferredContentSizeCategory)"#),
        layoutDirection: XCTestDynamicOverlay.unimplemented(
          #"@Dependnency(\.device.layoutDirection)"#, placeholder: .leftToRight),
        wristLocation: XCTestDynamicOverlay.unimplemented(
          #"@Dependnency(\.device.wristLocation)"#, placeholder: .right),
        crownOrientation: XCTestDynamicOverlay.unimplemented(
          #"@Dependnency(\.device.crownOrientation)"#, placeholder: .left),
        isBatteryMonitoringEnabled: (
          XCTestDynamicOverlay.unimplemented(
            #"@Dependnency(\.device.isBatteryMonitoringEnabled.get)"#),
          { _ in () }
        ),
        batteryState: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.batteryState)"#, placeholder: .unknown),
        batteryLevel: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.batteryLevel)"#),
        waterResistanceRating: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.waterResistanceRating)"#, placeholder: .ipx7),
        isWaterLockEnabled: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.isWaterLockEnabled)"#),
        supportsAudioStreaming: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.supportsAudioStreaming)"#),
        play: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.device.play)"#),
        enableWaterLock: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.enableWaterLock)"#)
      )
    }
  }
#endif

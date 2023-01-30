import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
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
      @ReadOnlyProxy public var name: String
      @ReadOnlyProxy public var model: String
      @ReadOnlyProxy public var localizedModel: String
      @ReadOnlyProxy public var systemName: String
      @ReadOnlyProxy public var systemVersion: String
      @ReadOnlyProxy public var identifierForVendor: UUID?
      @ReadOnlyProxy public var screenBounds: CGRect
      @ReadOnlyProxy public var screenScale: CGFloat
      @ReadOnlyProxy public var preferredContentSizeCategory: String
      @ReadOnlyProxy public var layoutDirection: WKInterfaceLayoutDirection
      @ReadOnlyProxy public var wristLocation: WKInterfaceDeviceWristLocation
      @ReadOnlyProxy public var crownOrientation: WKInterfaceDeviceCrownOrientation
      @ReadWriteProxy public var isBatteryMonitoringEnabled: Bool
      @ReadOnlyProxy public var batteryState: WKInterfaceDeviceBatteryState
      @ReadOnlyProxy public var batteryLevel: Float
      @ReadOnlyProxy public var waterResistanceRating: WKWaterResistanceRating
      @ReadOnlyProxy public var isWaterLockEnabled: Bool
      @ReadOnlyProxy public var supportsAudioStreaming: Bool
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
  }

  extension Device {
    public static var current: Device {
      .init(
        _implementation: .init(
          name: .init(WKInterfaceDevice.current().name),
          model: .init(WKInterfaceDevice.current().model),
          localizedModel: .init(WKInterfaceDevice.current().localizedModel),
          systemName: .init(WKInterfaceDevice.current().systemName),
          systemVersion: .init(WKInterfaceDevice.current().systemVersion),
          identifierForVendor: .init {
            if #available(watchOS 6.2, *) {
              return WKInterfaceDevice.current().identifierForVendor
            } else {
              // TODO: Add warning
              return nil
            }
          },
          screenBounds: .init(WKInterfaceDevice.current().screenBounds),
          screenScale: .init(WKInterfaceDevice.current().screenScale),
          preferredContentSizeCategory: .init(
            WKInterfaceDevice.current().preferredContentSizeCategory),
          layoutDirection: .init(WKInterfaceDevice.current().layoutDirection),
          wristLocation: .init(WKInterfaceDevice.current().wristLocation),
          crownOrientation: .init(WKInterfaceDevice.current().crownOrientation),
          isBatteryMonitoringEnabled: .init(
            .init(
              get: {
                WKInterfaceDevice.current().isBatteryMonitoringEnabled
              },
              set: {
                WKInterfaceDevice.current().isBatteryMonitoringEnabled = $0
              }
            )),
          batteryState: .init(WKInterfaceDevice.current().batteryState),
          batteryLevel: .init(WKInterfaceDevice.current().batteryLevel),
          waterResistanceRating: .init(WKInterfaceDevice.current().waterResistanceRating),
          isWaterLockEnabled: .init {
            if #available(watchOS 6.1, *) {
              return WKInterfaceDevice.current().isWaterLockEnabled
            } else {
              // TODO: Add warning
              return false
            }
          },
          supportsAudioStreaming: .init(WKInterfaceDevice.current().supportsAudioStreaming),
          play: .init { WKInterfaceDevice.current().play($0) },
          enableWaterLock: .init {
            {
              if #available(watchOS 6.1, *) {
                WKInterfaceDevice.current().enableWaterLock()
              } else {
                // TODO: Add warning
              }
            }
          }
        )
      )
    }
  }

  extension Device {
    public static var unimplemented: Device {
      .init(
        _implementation: .init(
          name: .unimplemented(#"Dependency(\.device.name)"#),
          model: .unimplemented(#"Dependency(\.device.model)"#),
          localizedModel: .unimplemented(#"Dependency(\.device.localizedModel)"#),
          systemName: .unimplemented(#"Dependency(\.device.systemName)"#),
          systemVersion: .unimplemented(#"Dependency(\.device.systemVersion)"#),
          identifierForVendor: .unimplemented(
            #"Dependency(\.device.identifierForVendor)"#, placeholder: .init()),
          screenBounds: .unimplemented(#"Dependency(\.device.screenBounds)"#, placeholder: .zero),
          screenScale: .unimplemented(#"Dependency(\.device.screenScale)"#),
          preferredContentSizeCategory: .unimplemented(
            #"Dependency(\.device.preferredContentSizeCategory)"#),
          layoutDirection: .unimplemented(
            #"Dependency(\.device.layoutDirection)"#, placeholder: .leftToRight),
          wristLocation: .unimplemented(#"Dependency(\.device.wristLocation)"#, placeholder: .left),
          crownOrientation: .unimplemented(
            #"Dependency(\.device.crownOrientation)"#, placeholder: .right),
          isBatteryMonitoringEnabled: .unimplemented(
            #"Dependency(\.device.isBatteryMonitoringEnabled.get)"#),
          batteryState: .unimplemented(
            #"Dependency(\.device.batteryState)"#, placeholder: .unknown),
          batteryLevel: .unimplemented(#"Dependency(\.device.batteryLevel)"#),
          waterResistanceRating: .unimplemented(
            #"Dependency(\.device.waterResistanceRating)"#, placeholder: .ipx7),
          isWaterLockEnabled: .unimplemented(#"Dependency(\.device.isWaterLockEnabled)"#),
          supportsAudioStreaming: .unimplemented(#"Dependency(\.device.supportsAudioStreaming)"#),
          play: .unimplemented(#"Dependency(\.device.play)"#),
          enableWaterLock: .unimplemented(#"Dependency(\.device.enableWaterLock)"#)
        )
      )
    }
  }
#endif

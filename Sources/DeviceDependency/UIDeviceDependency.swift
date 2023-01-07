import Dependencies
@_spi(Internals) import DependenciesAdditions
import Foundation
import XCTestDynamicOverlay

#if os(iOS) || os(tvOS)
  import UIKit.UIDevice

  extension DependencyValues {
    /// A representation of the current device.
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

  /// A representation of the current device.
  public struct Device: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      @MainActorReadOnlyProxy public var name: String
      @MainActorReadOnlyProxy public var model: String
      @MainActorReadOnlyProxy public var localizedModel: String
      @MainActorReadOnlyProxy public var systemName: String
      @MainActorReadOnlyProxy public var systemVersion: String
      @MainActorReadOnlyProxy public var identifierForVendor: UUID?
      @MainActorReadOnlyProxy public var orientation: UIDeviceOrientation
      @MainActorReadOnlyProxy public var isGeneratingDeviceOrientationNotifications: Bool
      @FunctionProxy public var beginGeneratingDeviceOrientationNotifications:
        @MainActor @Sendable () -> Void
      @FunctionProxy public var endGeneratingDeviceOrientationNotifications:
        @MainActor @Sendable () -> Void
      @MainActorReadWriteProxy public var isBatteryMonitoringEnabled: Bool
      @MainActorReadOnlyProxy public var batteryState: UIDevice.BatteryState
      @MainActorReadOnlyProxy public var batteryLevel: Float
      @MainActorReadWriteProxy public var isProximityMonitoringEnabled: Bool
      @MainActorReadOnlyProxy public var proximityState: Bool
      @MainActorReadOnlyProxy public var isMultitaskingSupported: Bool
      @MainActorReadOnlyProxy public var userInterfaceIdiom: UIUserInterfaceIdiom
      @FunctionProxy public var playInputClick: @MainActor @Sendable () -> Void

      init(
        name: MainActorReadOnlyProxy<String>,
        model: MainActorReadOnlyProxy<String>,
        localizedModel: MainActorReadOnlyProxy<String>,
        systemName: MainActorReadOnlyProxy<String>,
        systemVersion: MainActorReadOnlyProxy<String>,
        identifierForVendor: MainActorReadOnlyProxy<UUID?>,
        orientation: MainActorReadOnlyProxy<UIDeviceOrientation>,
        isGeneratingDeviceOrientationNotifications: MainActorReadOnlyProxy<Bool>,
        beginGeneratingDeviceOrientationNotifications: FunctionProxy<
          @MainActor @Sendable () -> Void
        >,
        endGeneratingDeviceOrientationNotifications: FunctionProxy<@MainActor @Sendable () -> Void>,
        isBatteryMonitoringEnabled: MainActorReadWriteProxy<Bool>,
        batteryState: MainActorReadOnlyProxy<UIDevice.BatteryState>,
        batteryLevel: MainActorReadOnlyProxy<Float>,
        isProximityMonitoringEnabled: MainActorReadWriteProxy<Bool>,
        proximityState: MainActorReadOnlyProxy<Bool>,
        isMultitaskingSupported: MainActorReadOnlyProxy<Bool>,
        userInterfaceIdiom: MainActorReadOnlyProxy<UIUserInterfaceIdiom>,
        playInputClick: FunctionProxy<@MainActor @Sendable () -> Void>
      ) {
        self._name = name
        self._model = model
        self._localizedModel = localizedModel
        self._systemName = systemName
        self._systemVersion = systemVersion
        self._identifierForVendor = identifierForVendor
        self._orientation = orientation
        self._isGeneratingDeviceOrientationNotifications =
          isGeneratingDeviceOrientationNotifications
        self._beginGeneratingDeviceOrientationNotifications =
          beginGeneratingDeviceOrientationNotifications
        self._endGeneratingDeviceOrientationNotifications =
          endGeneratingDeviceOrientationNotifications
        self._isBatteryMonitoringEnabled = isBatteryMonitoringEnabled
        self._batteryState = batteryState
        self._batteryLevel = batteryLevel
        self._isProximityMonitoringEnabled = isProximityMonitoringEnabled
        self._proximityState = proximityState
        self._isMultitaskingSupported = isMultitaskingSupported
        self._userInterfaceIdiom = userInterfaceIdiom
        self._playInputClick = playInputClick
      }
    }

    @_spi(Internals) public var _implementation: Implementation

    /// The name of the device.
    @MainActor
    public var name: String {
      self._implementation.name
    }
    /// The model of the device.
    @MainActor
    public var model: String {
      self._implementation.model
    }
    /// The model of the device as a localized string.
    @MainActor
    public var localizedModel: String {
      self._implementation.localizedModel
    }
    /// The name of the operating system running on the device.
    @MainActor
    public var systemName: String {
      self._implementation.systemName
    }
    /// The current version of the operating system.
    @MainActor
    public var systemVersion: String {
      self._implementation.systemVersion
    }
    /// An alphanumeric string that uniquely identifies a device to the app’s vendor.
    @MainActor
    public var identifierForVendor: UUID? {
      self._implementation.identifierForVendor
    }
    /// The physical orientation of the device.
    @MainActor
    public var orientation: UIDeviceOrientation {
      self._implementation.orientation
    }
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MainActor
    public var isGeneratingDeviceOrientationNotifications: Bool {
      self._implementation.isGeneratingDeviceOrientationNotifications
    }
    /// Begins the generation of notifications of device orientation changes.
    @MainActor
    public func beginGeneratingDeviceOrientationNotifications() {
      self._implementation.beginGeneratingDeviceOrientationNotifications()
    }
    /// Ends the generation of notifications of device orientation changes.
    @MainActor
    public func endGeneratingDeviceOrientationNotifications() {
      self._implementation.endGeneratingDeviceOrientationNotifications()
    }
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MainActor
    public var isBatteryMonitoringEnabled: Bool {
      get { self._implementation.isBatteryMonitoringEnabled }
      nonmutating set { self._implementation.isBatteryMonitoringEnabled = newValue }
    }
    /// The battery state for the device.
    @MainActor
    public var batteryState: UIDevice.BatteryState {
      self._implementation.batteryState
    }
    /// The battery charge level for the device.
    @MainActor
    public var batteryLevel: Float {
      self._implementation.batteryLevel
    }
    /// A Boolean value that indicates whether proximity monitoring is enabled.
    @MainActor
    public var isProximityMonitoringEnabled: Bool {
      get { self._implementation.isProximityMonitoringEnabled }
      nonmutating set { self._implementation.isProximityMonitoringEnabled = newValue }
    }
    /// A Boolean value that indicates whether the proximity sensor is close to the user.
    @MainActor
    public var proximityState: Bool {
      self._implementation.proximityState
    }
    /// A Boolean value that indicates whether the current device supports multitasking.
    @MainActor
    public var isMultitaskingSupported: Bool {
      self._implementation.isMultitaskingSupported
    }
    /// The style of interface to use on the current device.
    @MainActor
    public var userInterfaceIdiom: UIUserInterfaceIdiom {
      self._implementation.userInterfaceIdiom
    }
    /// Plays an input click in an enabled input view.
    @MainActor
    public func playInputClick() {
      self._implementation.playInputClick()
    }

    nonisolated  // Don't know why this is needed, as `Device` is not actor-isolated
      init(
        name: @escaping @MainActor @Sendable () -> String,
        model: @escaping @MainActor @Sendable () -> String,
        localizedModel: @escaping @MainActor @Sendable () -> String,
        systemName: @escaping @MainActor @Sendable () -> String,
        systemVersion: @escaping @MainActor @Sendable () -> String,
        identifierForVendor: @escaping @MainActor @Sendable () -> UUID?,
        orientation: @escaping @MainActor @Sendable () -> UIDeviceOrientation,
        isGeneratingDeviceOrientationNotifications: @escaping @MainActor @Sendable () -> Bool,
        isBatteryMonitoringEnabled: (
          get: @MainActor @Sendable () -> Bool, set: @MainActor @Sendable (Bool) -> Void
        ),
        batteryState: @escaping @MainActor @Sendable () -> UIDevice.BatteryState,
        batteryLevel: @escaping @MainActor @Sendable () -> Float,
        isProximityMonitoringEnabled: (
          get: @MainActor @Sendable () -> Bool, set: @MainActor @Sendable (Bool) -> Void
        ),
        proximityState: @escaping @MainActor @Sendable () -> Bool,
        isMultitaskingSupported: @escaping @MainActor @Sendable () -> Bool,
        userInterfaceIdiom: @escaping @MainActor @Sendable () -> UIUserInterfaceIdiom,

        beginGeneratingDeviceOrientationNotifications: @escaping @MainActor @Sendable () -> Void,
        endGeneratingDeviceOrientationNotifications: @escaping @MainActor @Sendable () -> Void,
        playInputClick: @escaping @MainActor @Sendable () -> Void
      )
    {
      self._implementation = .init(
        name: .init(name),
        model: .init(model),
        localizedModel: .init(localizedModel),
        systemName: .init(systemName),
        systemVersion: .init(systemVersion),
        identifierForVendor: .init(identifierForVendor),
        orientation: .init(orientation),
        isGeneratingDeviceOrientationNotifications: .init(
          isGeneratingDeviceOrientationNotifications),
        beginGeneratingDeviceOrientationNotifications: .init({
          { beginGeneratingDeviceOrientationNotifications() }
        }),
        endGeneratingDeviceOrientationNotifications: .init({
          { endGeneratingDeviceOrientationNotifications() }
        }),
        isBatteryMonitoringEnabled: .init(.init(isBatteryMonitoringEnabled)),
        batteryState: .init(batteryState),
        batteryLevel: .init(batteryLevel),
        isProximityMonitoringEnabled: .init(.init(isProximityMonitoringEnabled)),
        proximityState: .init(proximityState),
        isMultitaskingSupported: .init(isMultitaskingSupported),
        userInterfaceIdiom: .init(userInterfaceIdiom),
        playInputClick: .init({ { playInputClick() } })
      )
    }
  }

  extension Device {
    public nonisolated static var current: Device {
      Device(
        name: { UIDevice.current.name },
        model: { UIDevice.current.model },
        localizedModel: { UIDevice.current.localizedModel },
        systemName: { UIDevice.current.systemName },
        systemVersion: { UIDevice.current.systemVersion },
        identifierForVendor: { UIDevice.current.identifierForVendor },
        orientation: { UIDevice.current.orientation },
        isGeneratingDeviceOrientationNotifications: {
          UIDevice.current.isGeneratingDeviceOrientationNotifications
        },
        isBatteryMonitoringEnabled: (
          { UIDevice.current.isBatteryMonitoringEnabled },
          { UIDevice.current.isBatteryMonitoringEnabled = $0 }
        ),
        batteryState: { UIDevice.current.batteryState },
        batteryLevel: { UIDevice.current.batteryLevel },
        isProximityMonitoringEnabled: (
          { UIDevice.current.isProximityMonitoringEnabled },
          { UIDevice.current.isProximityMonitoringEnabled = $0 }
        ),
        proximityState: { UIDevice.current.proximityState },
        isMultitaskingSupported: { UIDevice.current.isMultitaskingSupported },
        userInterfaceIdiom: { UIDevice.current.userInterfaceIdiom },
        beginGeneratingDeviceOrientationNotifications: {
          UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        },
        endGeneratingDeviceOrientationNotifications: {
          UIDevice.current.endGeneratingDeviceOrientationNotifications()
        },
        playInputClick: { UIDevice.current.playInputClick() }
      )
    }
  }

  extension Device {
    public nonisolated
      static var unimplemented: Device
    {
      Device(
        name: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.name)"#),
        model: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.model)"#),
        localizedModel: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.localizedModel)"#),
        systemName: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.systemName)"#),
        systemVersion: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.systemVersion)"#),
        identifierForVendor: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.identifierForVendor)"#, placeholder: nil),
        orientation: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.orientation)"#, placeholder: .unknown),
        isGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.isGeneratingDeviceOrientationNotifications)"#),
        isBatteryMonitoringEnabled: (
          XCTestDynamicOverlay.unimplemented(
            #"@Dependency(\.device.isBatteryMonitoringEnabled.get)"#),
          { _ in () }
        ),
        batteryState: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.batteryState)"#, placeholder: .unknown),
        batteryLevel: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.batteryLevel)"#),
        isProximityMonitoringEnabled: (
          XCTestDynamicOverlay.unimplemented(
            #"@Dependency(\.device.isProximityMonitoringEnabled.get)"#),
          { _ in () }
        ),
        proximityState: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.proximityState)"#),
        isMultitaskingSupported: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.isMultitaskingSupported)"#),
        userInterfaceIdiom: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.userInterfaceIdiom)"#, placeholder: .phone),
        beginGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.beginGeneratingDeviceOrientationNotifications)"#),
        endGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.endGeneratingDeviceOrientationNotifications)"#),
        playInputClick: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.playInputClick)"#)
      )
    }
  }
#endif

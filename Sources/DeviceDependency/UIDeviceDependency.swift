import Dependencies
import DependenciesAdditions
import Foundation
import XCTestDynamicOverlay

// TODO: WKInterfaceDevice

#if os(iOS) || os(tvOS)
  extension DependencyValues {
    public var device: Device {
      get { self[DeviceKey.self] }
      set { self[DeviceKey.self] = newValue }
    }
  }

  import UIKit.UIDevice
  public struct Device: Sendable {
    /// The name of the device.
    @MALP public var name: String
    /// The model of the device.
    @MALP public var model: String
    /// The model of the device as a localized string.
    @MALP public var localizedModel: String
    /// The name of the operating system running on the device.
    @MALP public var systemName: String
    /// The current version of the operating system.
    @MALP public var systemVersion: String
    /// An alphanumeric string that uniquely identifies a device to the app’s vendor.
    @MALP public var identifierForVendor: UUID?
    /// The physical orientation of the device.
    @MALP public var orientation: UIDeviceOrientation
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MALP public var isGeneratingDeviceOrientationNotifications: Bool
    /// Begins the generation of notifications of device orientation changes.
    @MALP public var beginGeneratingDeviceOrientationNotifications: () -> Void
    /// Ends the generation of notifications of device orientation changes.
    @MALP public var endGeneratingDeviceOrientationNotifications: () -> Void
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MALP public var isBatteryMonitoringEnabled: Bool
    /// The battery state for the device.
    @MALP public var batteryState: UIDevice.BatteryState
    /// The battery charge level for the device.
    @MALP public var batteryLevel: Float
    /// A Boolean value that indicates whether proximity monitoring is enabled.
    @MALP public var isProximityMonitoringEnabled: Bool
    /// A Boolean value that indicates whether the proximity sensor is close to the user.
    @MALP public var proximityState: Bool
    /// A Boolean value that indicates whether the current device supports multitasking.
    @MALP public var isMultitaskingSupported: Bool
    /// The style of interface to use on the current device.
    @MALP public var userInterfaceIdiom: UIUserInterfaceIdiom
    /// Plays an input click in an enabled input view.
    @MALP public var playInputClick: () -> Void

    nonisolated  // Don't know why this is needed, as `Device` is not actor-isolated
      init(
        name: @escaping @MainActor () -> String,
        model: @escaping @MainActor () -> String,
        localizedModel: @escaping @MainActor () -> String,
        systemName: @escaping @MainActor () -> String,
        systemVersion: @escaping @MainActor () -> String,
        identifierForVendor: @escaping @MainActor () -> UUID?,
        orientation: @escaping @MainActor () -> UIDeviceOrientation,
        isGeneratingDeviceOrientationNotifications: @escaping @MainActor () -> Bool,
        isBatteryMonitoringEnabled: @escaping @MainActor () -> Bool,
        batteryState: @escaping @MainActor () -> UIDevice.BatteryState,
        batteryLevel: @escaping @MainActor () -> Float,
        isProximityMonitoringEnabled: @escaping @MainActor () -> Bool,
        proximityState: @escaping @MainActor () -> Bool,
        isMultitaskingSupported: @escaping @MainActor () -> Bool,
        userInterfaceIdiom: @escaping @MainActor () -> UIUserInterfaceIdiom,

        beginGeneratingDeviceOrientationNotifications: @escaping @MainActor () -> Void,
        endGeneratingDeviceOrientationNotifications: @escaping @MainActor () -> Void,
        playInputClick: @escaping @MainActor () -> Void
      )
    {
      self._name = .init (name)
      self._model = .init(model)
      self._localizedModel = .init(localizedModel)
      self._systemName = .init(systemName)
      self._systemVersion = .init(systemVersion)
      self._identifierForVendor = .init(identifierForVendor)
      self._orientation = .init(orientation)
      self._isGeneratingDeviceOrientationNotifications = .init(
        isGeneratingDeviceOrientationNotifications)
      self._isBatteryMonitoringEnabled = .init(isBatteryMonitoringEnabled)
      self._batteryState = .init(batteryState)
      self._batteryLevel = .init(batteryLevel)
      self._isProximityMonitoringEnabled = .init(isProximityMonitoringEnabled)
      self._proximityState = .init(proximityState)
      self._isMultitaskingSupported = .init(isMultitaskingSupported)
      self._userInterfaceIdiom = .init(userInterfaceIdiom)

      self._beginGeneratingDeviceOrientationNotifications = .init {
        { beginGeneratingDeviceOrientationNotifications() }
      }
      self._endGeneratingDeviceOrientationNotifications = .init {
        { beginGeneratingDeviceOrientationNotifications() }
      }
      self._playInputClick = .init { { playInputClick() } }
    }
  }

  enum DeviceKey: DependencyKey {
    public static var liveValue: Device {
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
        isBatteryMonitoringEnabled: { UIDevice.current.isBatteryMonitoringEnabled },
        batteryState: { UIDevice.current.batteryState },
        batteryLevel: { UIDevice.current.batteryLevel },
        isProximityMonitoringEnabled: { UIDevice.current.isProximityMonitoringEnabled },
        proximityState: { UIDevice.current.proximityState },
        isMultitaskingSupported: { UIDevice.current.isMultitaskingSupported },
        userInterfaceIdiom: { UIDevice.current.userInterfaceIdiom },
        beginGeneratingDeviceOrientationNotifications: {
          UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        },
        endGeneratingDeviceOrientationNotifications: {
          UIDevice.current.endGeneratingDeviceOrientationNotifications()
        },
        playInputClick: { UIDevice.current.playInputClick() })
    }

    public static var testValue: Device {
      .unimplemented
    }
  }

  extension Device {
    public nonisolated  // Don't know why this is needed, as `Device` is not actor-isolated
      static var unimplemented: Device
    {
      Device(
        name: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.name)"#),
        model: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.model)"#),
        localizedModel: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.localizedModel)"#),
        systemName: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.systemName)"#),
        systemVersion: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.systemVersion)"#),
        identifierForVendor: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.identifierForVendor)"#),
        orientation: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.orientation)"#),
        isGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.isGeneratingDeviceOrientationNotifications)"#),
        isBatteryMonitoringEnabled: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.isBatteryMonitoringEnabled)"#),
        batteryState: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.batteryState)"#),
        batteryLevel: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.batteryLevel)"#),
        isProximityMonitoringEnabled: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.isProximityMonitoringEnabled)"#),
        proximityState: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.proximityState)"#),
        isMultitaskingSupported: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.isMultitaskingSupported)"#),
        userInterfaceIdiom: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.userInterfaceIdiom)"#),
        beginGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.beginGeneratingDeviceOrientationNotifications)"#),
        endGeneratingDeviceOrientationNotifications: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.endGeneratingDeviceOrientationNotifications)"#),
        playInputClick: XCTestDynamicOverlay.unimplemented(
          #"Unimplemented: @Dependency(\.device.playInputClick)"#)
      )
    }
  }
#endif

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
    @MainActorLazyProxy public var name: String
    /// The model of the device.
    @MainActorLazyProxy public var model: String
    /// The model of the device as a localized string.
    @MainActorLazyProxy public var localizedModel: String
    /// The name of the operating system running on the device.
    @MainActorLazyProxy public var systemName: String
    /// The current version of the operating system.
    @MainActorLazyProxy public var systemVersion: String
    /// An alphanumeric string that uniquely identifies a device to the app’s vendor.
    @MainActorLazyProxy public var identifierForVendor: UUID?
    /// The physical orientation of the device.
    @MainActorLazyProxy public var orientation: UIDeviceOrientation
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MainActorLazyProxy public var isGeneratingDeviceOrientationNotifications: Bool
    /// Begins the generation of notifications of device orientation changes.
    @MainActorLazyProxy public var beginGeneratingDeviceOrientationNotifications: () -> Void
    /// Ends the generation of notifications of device orientation changes.
    @MainActorLazyProxy public var endGeneratingDeviceOrientationNotifications: () -> Void
    /// A Boolean value that indicates whether battery monitoring is enabled.
    @MainActorLazyProxy public var isBatteryMonitoringEnabled: Bool
    /// The battery state for the device.
    @MainActorLazyProxy public var batteryState: UIDevice.BatteryState
    /// The battery charge level for the device.
    @MainActorLazyProxy public var batteryLevel: Float
    /// A Boolean value that indicates whether proximity monitoring is enabled.
    @MainActorLazyProxy public var isProximityMonitoringEnabled: Bool
    /// A Boolean value that indicates whether the proximity sensor is close to the user.
    @MainActorLazyProxy public var proximityState: Bool
    /// A Boolean value that indicates whether the current device supports multitasking.
    @MainActorLazyProxy public var isMultitaskingSupported: Bool
    /// The style of interface to use on the current device.
    @MainActorLazyProxy public var userInterfaceIdiom: UIUserInterfaceIdiom
    /// Plays an input click in an enabled input view.
    @MainActorLazyProxy public var playInputClick: () -> Void

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
      self._name = .init { name() }
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
      typealias __ = XCTestDynamicOverlay
      Device(
        name: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.name)"#),
        model: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.model)"#),
        localizedModel: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.localizedModel)"#),
        systemName: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.systemName)"#),
        systemVersion: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.systemVersion)"#),
        identifierForVendor: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.identifierForVendor)"#),
        orientation: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.orientation)"#),
        isGeneratingDeviceOrientationNotifications: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.isGeneratingDeviceOrientationNotifications)"#),
        isBatteryMonitoringEnabled: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.isBatteryMonitoringEnabled)"#),
        batteryState: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.batteryState)"#),
        batteryLevel: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.batteryLevel)"#),
        isProximityMonitoringEnabled: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.isProximityMonitoringEnabled)"#),
        proximityState: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.proximityState)"#),
        isMultitaskingSupported: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.isMultitaskingSupported)"#),
        userInterfaceIdiom: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.userInterfaceIdiom)"#),
        beginGeneratingDeviceOrientationNotifications: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.beginGeneratingDeviceOrientationNotifications)"#),
        endGeneratingDeviceOrientationNotifications: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.endGeneratingDeviceOrientationNotifications)"#),
        playInputClick: __.unimplemented(
          #"Unimplemented: @Dependency(\.device.playInputClick)"#)
      )
    }
  }
#endif

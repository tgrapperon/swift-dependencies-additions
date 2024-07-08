import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import XCTestDynamicOverlay

#if os(iOS) || os(visionOS)
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
  }

  extension Device {
    public nonisolated static var current: Device {
      return Device(
        _implementation: .init(
          name: .init { UIDevice.current.name },
          model: .init { UIDevice.current.model },
          localizedModel: .init { UIDevice.current.localizedModel },
          systemName: .init { UIDevice.current.systemName },
          systemVersion: .init { UIDevice.current.systemVersion },
          identifierForVendor: .init { UIDevice.current.identifierForVendor },
          orientation: .init {
            #if swift(>=5.9) && os(visionOS)
              return UIDeviceOrientation.unknown
            #else
              UIDevice.current.orientation
            #endif
          },
          isGeneratingDeviceOrientationNotifications: .init {
            #if swift(>=5.9) && os(visionOS)
              return false
            #else
              UIDevice.current.isGeneratingDeviceOrientationNotifications
            #endif
          },
          beginGeneratingDeviceOrientationNotifications: .init {
            #if swift(>=5.9) && os(visionOS)
              return
            #else
              UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            #endif
          },
          endGeneratingDeviceOrientationNotifications: .init {
            #if swift(>=5.9) && os(visionOS)
              return
            #else
              UIDevice.current.endGeneratingDeviceOrientationNotifications()
            #endif
          },
          isBatteryMonitoringEnabled: .init(
            .init {
              UIDevice.current.isBatteryMonitoringEnabled
            } set: {
              UIDevice.current.isBatteryMonitoringEnabled = $0
            }),
          batteryState: .init { UIDevice.current.batteryState },
          batteryLevel: .init { UIDevice.current.batteryLevel },
          isProximityMonitoringEnabled: .init(
            .init {
              UIDevice.current.isProximityMonitoringEnabled
            } set: {
              UIDevice.current.isProximityMonitoringEnabled = $0
            }),
          proximityState: .init { UIDevice.current.proximityState },
          isMultitaskingSupported: .init { UIDevice.current.isMultitaskingSupported },
          userInterfaceIdiom: .init { UIDevice.current.userInterfaceIdiom },
          playInputClick: .init {
            #if swift(>=5.9) && os(visionOS)
              return
            #else
              UIDevice.current.playInputClick()
            #endif
          }
        )
      )
    }
  }

  extension Device {
    public nonisolated
      static var unimplemented: Device
    {
      Device(
        _implementation: .init(
          name: .unimplemented(
            #"@Dependency(\.device.name)"#),
          model: .unimplemented(
            #"@Dependency(\.device.model)"#),
          localizedModel: .unimplemented(
            #"@Dependency(\.device.localizedModel)"#),
          systemName: .unimplemented(
            #"@Dependency(\.device.systemName)"#),
          systemVersion: .unimplemented(
            #"@Dependency(\.device.systemVersion)"#),
          identifierForVendor: .unimplemented(
            #"@Dependency(\.device.identifierForVendor)"#, placeholder: nil),
          orientation: .unimplemented(
            #"@Dependency(\.device.orientation)"#, placeholder: .unknown),
          isGeneratingDeviceOrientationNotifications: .unimplemented(
            #"@Dependency(\.device.isGeneratingDeviceOrientationNotifications)"#),
          beginGeneratingDeviceOrientationNotifications: .unimplemented(
            #"@Dependency(\.device.beginGeneratingDeviceOrientationNotifications)"#),
          endGeneratingDeviceOrientationNotifications: .unimplemented(
            #"@Dependency(\.device.endGeneratingDeviceOrientationNotifications)"#),
          isBatteryMonitoringEnabled: .init(
            .unimplemented(#"@Dependency(\.device.isBatteryMonitoringEnabled.get)"#)),
          batteryState: .unimplemented(
            #"@Dependency(\.device.batteryState)"#, placeholder: .unknown),
          batteryLevel: .unimplemented(
            #"@Dependency(\.device.batteryLevel)"#),
          isProximityMonitoringEnabled:
            .unimplemented(
              #"@Dependency(\.device.isProximityMonitoringEnabled.get)"#),
          proximityState: .unimplemented(
            #"@Dependency(\.device.proximityState)"#),
          isMultitaskingSupported: .unimplemented(
            #"@Dependency(\.device.isMultitaskingSupported)"#),
          userInterfaceIdiom: .unimplemented(
            #"@Dependency(\.device.userInterfaceIdiom)"#, placeholder: .phone),
          playInputClick: .unimplemented(
            #"@Dependency(\.device.playInputClick)"#)
        )
      )
    }
  }
#endif

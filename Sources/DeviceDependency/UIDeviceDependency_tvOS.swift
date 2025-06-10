import Dependencies
import DependenciesAdditionsBasics
import Foundation
import IssueReporting

#if os(tvOS)
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
      @MainActorReadWriteProxy public var isProximityMonitoringEnabled: Bool
      @MainActorReadOnlyProxy public var proximityState: Bool
      @MainActorReadOnlyProxy public var isMultitaskingSupported: Bool
      @MainActorReadOnlyProxy public var userInterfaceIdiom: UIUserInterfaceIdiom
      @FunctionProxy public var playInputClick: @MainActor @Sendable () -> Void
    }

    public var _implementation: Implementation

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
            UIDevice.current.playInputClick()
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
            #"@Dependency(\.device.name)"#, placeholder: ""),
          model: .unimplemented(
            #"@Dependency(\.device.model)"#, placeholder: ""),
          localizedModel: .unimplemented(
            #"@Dependency(\.device.localizedModel)"#, placeholder: ""),
          systemName: .unimplemented(
            #"@Dependency(\.device.systemName)"#, placeholder: ""),
          systemVersion: .unimplemented(
            #"@Dependency(\.device.systemVersion)"#, placeholder: ""),
          identifierForVendor: .unimplemented(
            #"@Dependency(\.device.identifierForVendor)"#, placeholder: nil),
          isProximityMonitoringEnabled:
            .unimplemented(
              #"@Dependency(\.device.isProximityMonitoringEnabled.get)"#, placeholder: false),
          proximityState: .unimplemented(
            #"@Dependency(\.device.proximityState)"#, placeholder: false),
          isMultitaskingSupported: .unimplemented(
            #"@Dependency(\.device.isMultitaskingSupported)"#, placeholder: false),
          userInterfaceIdiom: .unimplemented(
            #"@Dependency(\.device.userInterfaceIdiom)"#, placeholder: .phone),
          playInputClick: .unimplemented(
            #"@Dependency(\.device.playInputClick)"#, placeholder: {})
        )
      )
    }
  }
#endif

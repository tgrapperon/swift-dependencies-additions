import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import XCTestDynamicOverlay

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

    nonisolated
      init(
        name: @escaping @MainActor @Sendable () -> String,
        model: @escaping @MainActor @Sendable () -> String,
        localizedModel: @escaping @MainActor @Sendable () -> String,
        systemName: @escaping @MainActor @Sendable () -> String,
        systemVersion: @escaping @MainActor @Sendable () -> String,
        identifierForVendor: @escaping @MainActor @Sendable () -> UUID?,
        isProximityMonitoringEnabled: (
          get: @MainActor @Sendable () -> Bool, set: @MainActor @Sendable (Bool) -> Void
        ),
        proximityState: @escaping @MainActor @Sendable () -> Bool,
        isMultitaskingSupported: @escaping @MainActor @Sendable () -> Bool,
        userInterfaceIdiom: @escaping @MainActor @Sendable () -> UIUserInterfaceIdiom,
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
        isProximityMonitoringEnabled: (
          { UIDevice.current.isProximityMonitoringEnabled },
          { UIDevice.current.isProximityMonitoringEnabled = $0 }
        ),
        proximityState: { UIDevice.current.proximityState },
        isMultitaskingSupported: { UIDevice.current.isMultitaskingSupported },
        userInterfaceIdiom: { UIDevice.current.userInterfaceIdiom },
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
        playInputClick: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.device.playInputClick)"#)
      )
    }
  }
#endif

#if canImport(DeviceCheck)
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import DeviceCheck
  import XCTestDynamicOverlay

  extension DependencyValues {
    public var deviceCheckDevice: DeviceCheckDevice {
      get { self[DeviceCheckDevice.self] }
      set { self[DeviceCheckDevice.self] = newValue }
    }
  }

  extension DeviceCheckDevice: DependencyKey {
    public static var liveValue: DeviceCheckDevice { .current }
    public static var testValue: DeviceCheckDevice { .unimplemented }
    public static var previewValue: DeviceCheckDevice { .current }
  }

  public struct DeviceCheckDevice: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      @ReadOnlyProxy public var isSupported: Bool
      @FunctionProxy public var generateToken: @Sendable () async throws -> Data
    }
    @_spi(Internals) public var _implementation: Implementation

    /// A Boolean value that indicates whether the device supports the DeviceCheck API.
    @available(iOS 11.0, macOS 10.15, tvOS 11.0, watchOS 9.0, *)
    public var isSupported: Bool {
      _implementation.isSupported
    }
    /// Generates a token that identifies the current device.
    @available(iOS 11.0, macOS 10.15, tvOS 11.0, watchOS 9.0, *)
    public func generateToken() async throws -> Data {
      try await _implementation.generateToken()
    }
  }

  extension DeviceCheckDevice {
    public init(
      isSupported: @autoclosure @escaping @Sendable () -> Bool,
      generateToken: @escaping @Sendable () async throws -> Data
    ) {
      self._implementation = .init(
        isSupported: .init(isSupported),
        generateToken: .init({ generateToken })
      )
    }
  }
  extension DeviceCheckDevice {
    public static var current: DeviceCheckDevice {
      return .init(
        _implementation: .init(
          isSupported: .init {
            if #available(iOS 11.0, macOS 10.15, tvOS 11.0, watchOS 9.0, *) {
              return DCDevice.current.isSupported
            }
            fatalError()
          },
          generateToken: .init {
            {
              if #available(iOS 11.0, macOS 10.15, tvOS 11.0, watchOS 9.0, *) {
                return try await DCDevice.current.generateToken()
              }
              fatalError()
            }
          }
        ))
    }

    public static var unimplemented: DeviceCheckDevice {
      .init(
        _implementation: .init(
          isSupported: .unimplemented(
            #"@Dependency(\.deviceCheck.isSupported)"#),
          generateToken: .unimplemented(
            #"@Dependency(\.deviceCheck.generateToken)"#,
            placeholder: { .init() }))
      )
    }
  }
#endif

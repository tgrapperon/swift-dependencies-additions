#if canImport(OSLog)
  import Dependencies
  import BundleInfo
  // Because of safety reasons, the compiler prevents to pass non-literal `OSLogMessage`s to a
  // `Logger` value. This prevents to create a `Sendable` wrapper. This value is however very likely
  // thread-safe (to be confirmed), so we can probably use `@preconcurrency` without problem for
  // now.
  @preconcurrency import OSLog

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension DependencyValues {
    public var logger: Logger {
      get { self[Logger.self] }
      set { self[Logger.self] = newValue }
    }
  }

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension Logger: DependencyKey {
    public static var liveValue: Logger { Logger() }
    public static var testValue: Logger {
      XCTFail(#"Unimplemented: @Dependency(\.logger)"#)
      return Logger()
    }
  }

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension Logger {
    public subscript(category: String) -> Logger {
      @Dependency(\.bundleInfo) var bundleInfo
      return Logger(subsystem: bundleInfo.bundleIdentifier, category: category)
    }
  }
#endif

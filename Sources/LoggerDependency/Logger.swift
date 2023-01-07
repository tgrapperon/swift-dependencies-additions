#if canImport(OSLog)
  import Dependencies

  import BundleDependency
  // Because of safety reasons, the compiler prevents to pass non-literal `OSLogMessage`s to a
  // `Logger` value. This prevents to create a `Sendable` wrapper. This value is however very likely
  // thread-safe (to be confirmed), so we can probably use `@preconcurrency` without problem for
  // now.
  // https://forums.swift.org/t/argument-must-be-a-static-method-or-property-of-oslogprivacy/38441/2
  @preconcurrency import OSLog

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension DependencyValues {
    /// A value for writing interpolated string messages to the unified logging system.
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
    public static var previewValue: Logger { Logger() }
  }

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  extension Logger {
    /// Creates a logger using the specified subsystem and category.
    ///
    /// You can use this subscript on the `\.logger` dependency:
    /// ```swift
    /// @Dependency(\.logger[subsystem: "Backend", category: "Transactions"]) var logger
    ///
    /// logger.log("Paid with bank account \(accountNumber)")
    /// ```
    public subscript(subsystem subsystem: String, category category: String) -> Logger {
      return Logger(subsystem: subsystem, category: category)
    }
    /// Creates a `Logger` value where messages are categorized by the provided argument.
    /// The `Logger`'s subsystem is the bundle identifier, extracted from the ``BundleInfo``
    /// dependency.
    ///
    /// You can use this subscript on the `\.logger` dependency:
    /// ```swift
    /// @Dependency(\.logger["Transactions"]) var logger
    ///
    /// logger.log("Paid with bank account \(accountNumber)")
    /// ```
    public subscript(category: String) -> Logger {
      @Dependency(\.bundleInfo) var bundleInfo
      return Logger(subsystem: bundleInfo.bundleIdentifier, category: category)
    }
  }
#endif

#if canImport(OSLog)
  import Dependencies

  import BundleDependency
  // Because of safety reasons, the compiler prevents to pass non-literal `OSLogMessage`s to a
  // `Logger` value. This prevents to create a `Sendable` wrapper. This value is however very likely
  // thread-safe (to be confirmed), so we can probably use `@preconcurrency` without problem for
  // now.
  // https://forums.swift.org/t/argument-must-be-a-static-method-or-property-of-oslogprivacy/38441/2
  @preconcurrency import OSLog
  import XCTestDynamicOverlay

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
    /// - Note: It doesn't make a lot of sense to fail by default because we can't pass an
    /// inspectable `Logger` value to assert logged messages when testing. Given the prominence of
    /// logging failing by default is more annoying than useful in real-life scenarios.
    /// Users who wish to assert that no logging occurs can override the `\.logger` dependency with
    /// the `.unimplemented` logger.
    public static var testValue: Logger { Logger() }
    public static var previewValue: Logger { Logger() }

    /// A `Logger` that fails when accessed while testing.
    public static var unimplemented: Logger {
      XCTFail(#"Unimplemented: @Dependency(\.logger)"#)
      return Logger()
    }
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
      Logger(subsystem: subsystem, category: category)
    }
    /// Creates a `Logger` value where messages are categorized by the provided argument.
    /// The `Logger`'s subsystem is the bundle identifier.
    ///
    /// You can use this subscript on the `\.logger` dependency:
    /// ```swift
    /// @Dependency(\.logger["Transactions"]) var logger
    ///
    /// logger.log("Paid with bank account \(accountNumber)")
    /// ```
    public subscript(category: String) -> Logger {
      Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
  }

  @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
  extension Logger {
    /// Creates a `OSSignposter` to emit signpost to this logger value.
    public var signpost: OSSignposter {
      OSSignposter(logger: self)
    }
  }
#endif

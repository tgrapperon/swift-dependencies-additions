#if os(iOS) || os(watchOS) || os(macOS) || os(visionOS)
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  @preconcurrency import UserNotifications
  import XCTestDynamicOverlay

  extension DependencyValues {
    /// An abstraction of `UNUserNotificationCenter`, the central object for managing
    /// notification-related activities for your app or app extension.
    public var userNotificationCenter: UserNotificationCenter {
      get { self[UserNotificationCenter.self] }
      set { self[UserNotificationCenter.self] = newValue }
    }
  }

  extension UserNotificationCenter: DependencyKey {
    public static var liveValue: UserNotificationCenter { .system }
    public static var testValue: UserNotificationCenter { .unimplemented }
    public static var previewValue: UserNotificationCenter { .system }
  }

  public struct UserNotificationCenter: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      @FunctionProxy public var notificationSettings: @Sendable () async -> UNNotificationSettings
      // Keeping this unexposed proxy around on watchOS crashes the compiler for some reason
      #if !os(watchOS)
        @FunctionProxy public var setBadgeCount: @Sendable (Int) async throws -> Void
      #endif
      @FunctionProxy public var requestAuthorization:
        @Sendable (UNAuthorizationOptions) async throws -> Bool
      @ReadWriteProxy public var delegate: (UNUserNotificationCenterDelegate & Sendable)?
      @ReadOnlyProxy public var supportsContentExtensions: Bool
      @FunctionProxy public var add: @Sendable (UNNotificationRequest) async throws -> Void
      @FunctionProxy public var pendingNotificationRequests:
        @Sendable () async -> [UNNotificationRequest]
      @FunctionProxy public var removePendingNotificationRequests: @Sendable ([String]) -> Void
      @FunctionProxy public var removeAllPendingNotificationRequests: @Sendable () -> Void
      @FunctionProxy public var deliveredNotifications: @Sendable () async -> [UNNotification]
      @FunctionProxy public var removeDeliveredNotifications: @Sendable ([String]) -> Void
      @FunctionProxy public var removeAllDeliveredNotifications: @Sendable () -> Void
      @FunctionProxy public var setNotificationCategories:
        @Sendable (Set<UNNotificationCategory>) -> Void
      @FunctionProxy public var notificationCategories:
        @Sendable () async -> Set<UNNotificationCategory>
    }

    @_spi(Internals) public var _implementation: Implementation

    /// The notification center’s delegate.
    public var delegate: (UNUserNotificationCenterDelegate & Sendable)? {
      get { self._implementation.delegate }
      nonmutating set { self._implementation.delegate = newValue }
    }
    /// A Boolean value that indicates whether the device supports notification content extensions.
    public var supportsContentExtensions: Bool {
      self._implementation.supportsContentExtensions
    }

    /// Retrieves the authorization and feature-related settings for your app.
    public func notificationSettings() async -> UNNotificationSettings {
      await self._implementation.notificationSettings()
    }

    /// Requests the user’s authorization to allow local and remote notifications for your app.
    public func requestAuthorization(options: UNAuthorizationOptions = []) async throws -> Bool {
      try await self._implementation.requestAuthorization(options)
    }

    /// Updates the badge count for your app’s icon.
    @available(iOS 16.0, macOS 13, *)
    @available(watchOS, unavailable)
    public func setBadgeCount(_ newBadgeCount: Int) async throws {
      #if !os(watchOS)
        try await self._implementation.setBadgeCount(newBadgeCount)
      #endif
    }

    /// Schedules the delivery of a local notification.
    public func add(_ request: UNNotificationRequest) async throws {
      try await self._implementation.add(request)
    }

    /// Fetches all of your app’s local notifications that are pending delivery.
    public func pendingNotificationRequests() async -> [UNNotificationRequest] {
      await self._implementation.pendingNotificationRequests()
    }

    /// Removes your app’s local notifications that are pending and match the specified identifiers.
    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
      self._implementation.removePendingNotificationRequests(identifiers)
    }

    /// Removes all of your app’s pending local notifications.
    public func removeAllPendingNotificationRequests() {
      self._implementation.removeAllPendingNotificationRequests()
    }

    /// Fetches all of your app’s delivered notifications that are still present in Notification Center.
    public func deliveredNotifications() async -> [UNNotification] {
      await self._implementation.deliveredNotifications()
    }

    /// Removes your app’s notifications from Notification Center that match the specified identifiers.
    public func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
      self._implementation.removeDeliveredNotifications(identifiers)
    }

    /// Removes all of your app’s delivered notifications from Notification Center.
    public func removeAllDeliveredNotifications() {
      self._implementation.removeAllDeliveredNotifications()
    }

    /// Registers the notification categories that your app supports.
    public func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
      self._implementation.setNotificationCategories(categories)
    }

    /// Fetches your app’s registered notification categories.
    public func notificationCategories() async -> Set<UNNotificationCategory> {
      await self._implementation.notificationCategories()
    }
  }

  extension UserNotificationCenter {
    static var system: Self {
      // Since we needed to remove the setBadge proxy to work around a compiler crash, we now need
      // a dedicated initializer.
      #if os(watchOS)
        return .init(
          _implementation: .init(
            notificationSettings: .init {
              await UNUserNotificationCenter.current().notificationSettings()
            },
            requestAuthorization: .init {
              try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
            },
            delegate: .init(
              .init(
                get: { UNUserNotificationCenter.current().delegate },
                set: { UNUserNotificationCenter.current().delegate = $0 }
              )),
            supportsContentExtensions: .init(
              UNUserNotificationCenter.current().supportsContentExtensions),
            add: .init {
              try await UNUserNotificationCenter.current().add($0)
            },
            pendingNotificationRequests: .init {
              await UNUserNotificationCenter.current().pendingNotificationRequests()
            },
            removePendingNotificationRequests: .init {
              UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: $0)
            },
            removeAllPendingNotificationRequests: .init {
              UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            },
            deliveredNotifications: .init {
              await UNUserNotificationCenter.current().deliveredNotifications()
            },
            removeDeliveredNotifications: .init {
              UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
            },
            removeAllDeliveredNotifications: .init {
              UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            },
            setNotificationCategories: .init {
              UNUserNotificationCenter.current().setNotificationCategories($0)
            },
            notificationCategories: .init {
              await UNUserNotificationCenter.current().notificationCategories()
            }
          )
        )
      #else
        return .init(
          _implementation: .init(
            notificationSettings: .init {
              await UNUserNotificationCenter.current().notificationSettings()
            },
            setBadgeCount: .init { count in
              if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
                #if !os(watchOS)
                  try await UNUserNotificationCenter.current().setBadgeCount(count)
                #endif
              } else {
                fatalError()
              }
            },
            requestAuthorization: .init {
              try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
            },
            delegate: .init(
              .init(
                get: { UNUserNotificationCenter.current().delegate },
                set: { UNUserNotificationCenter.current().delegate = $0 }
              )),
            supportsContentExtensions: .init(
              UNUserNotificationCenter.current().supportsContentExtensions),
            add: .init {
              try await UNUserNotificationCenter.current().add($0)
            },
            pendingNotificationRequests: .init {
              await UNUserNotificationCenter.current().pendingNotificationRequests()
            },
            removePendingNotificationRequests: .init {
              UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: $0)
            },
            removeAllPendingNotificationRequests: .init {
              UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            },
            deliveredNotifications: .init {
              await UNUserNotificationCenter.current().deliveredNotifications()
            },
            removeDeliveredNotifications: .init {
              UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
            },
            removeAllDeliveredNotifications: .init {
              UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            },
            setNotificationCategories: .init {
              UNUserNotificationCenter.current().setNotificationCategories($0)
            },
            notificationCategories: .init {
              await UNUserNotificationCenter.current().notificationCategories()
            }
          )
        )
      #endif
    }
  }

  extension UserNotificationCenter {
    static var unimplemented: UserNotificationCenter {
      #if os(watchOS)
        UserNotificationCenter(
          _implementation: .init(
            notificationSettings: .unimplemented(
              #"@Dependency(\.userNotificationCenter.notificationSettings)"#,
              placeholder: { fatalError() }),
            requestAuthorization: .unimplemented(
              #"@Dependency(\.userNotificationCenter.requestAuthorization)"#),
            delegate: .unimplemented(
              #"@Dependency(\.userNotificationCenter.delegate.get)"#,
              placeholder: nil
            ),
            supportsContentExtensions: .unimplemented(
              #"@Dependency(\.userNotificationCenter.supportsContentExtensions)"#),
            add: .unimplemented(
              #"@Dependency(\.userNotificationCenter.add)"#),
            pendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.pendingNotificationRequests)"#),
            removePendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removePendingNotificationRequests)"#),
            removeAllPendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeAllPendingNotificationRequests)"#),
            deliveredNotifications: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.deliveredNotifications)"#),
            removeDeliveredNotifications: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeDeliveredNotifications)"#),
            removeAllDeliveredNotifications: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeAllDeliveredNotifications)"#),
            setNotificationCategories: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.setNotificationCategories)"#),
            notificationCategories: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.notificationCategories)"#)
          )
        )
      #else
        UserNotificationCenter(
          _implementation: .init(
            notificationSettings: .unimplemented(
              #"@Dependency(\.userNotificationCenter.notificationSettings)"#,
              placeholder: { fatalError() }),
            setBadgeCount: .unimplemented(
              #"@Dependency(\.userNotificationCenter.setBadgeCount)"#),
            requestAuthorization: .unimplemented(
              #"@Dependency(\.userNotificationCenter.requestAuthorization)"#),
            delegate: .unimplemented(
              #"@Dependency(\.userNotificationCenter.delegate.get)"#,
              placeholder: nil
            ),
            supportsContentExtensions: .unimplemented(
              #"@Dependency(\.userNotificationCenter.supportsContentExtensions)"#),
            add: .unimplemented(
              #"@Dependency(\.userNotificationCenter.add)"#),
            pendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.pendingNotificationRequests)"#),
            removePendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removePendingNotificationRequests)"#),
            removeAllPendingNotificationRequests: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeAllPendingNotificationRequests)"#),
            deliveredNotifications: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.deliveredNotifications)"#),
            removeDeliveredNotifications: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeDeliveredNotifications)"#),
            removeAllDeliveredNotifications: .unimplemented(
              #"@Dependency(\.userNotificationCenter.removeAllDeliveredNotifications)"#),
            setNotificationCategories: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.setNotificationCategories)"#),
            notificationCategories: .unimplemented(
              #"@Dependency(\,.userNotificationCenter.notificationCategories)"#)
          )
        )
      #endif
    }
  }
#endif

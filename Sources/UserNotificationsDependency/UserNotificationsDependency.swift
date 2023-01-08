#if os(iOS) || os(watchOS) || os(macOS)
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
      @FunctionProxy public var setBadgeCount: @Sendable (Int) async throws -> Void
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
      try await self._implementation.setBadgeCount(newBadgeCount)
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

    init(
      notificationSettings: @escaping @Sendable () async -> UNNotificationSettings,
      setBadgeCount: @escaping @Sendable (Int) async throws -> Void,
      requestAuthorization: @escaping @Sendable (UNAuthorizationOptions) async throws -> Bool,
      delegate: (
        @Sendable () -> (UNUserNotificationCenterDelegate & Sendable)?,
        @Sendable ((UNUserNotificationCenterDelegate & Sendable)?) -> Void
      ),
      supportsContentExtensions: @Sendable @escaping @autoclosure () -> Bool,
      add: @escaping @Sendable (UNNotificationRequest) async throws -> Void,
      pendingNotificationRequests: @escaping @Sendable () async -> [UNNotificationRequest],
      removePendingNotificationRequests: @escaping @Sendable ([String]) -> Void,
      removeAllPendingNotificationRequests: @escaping @Sendable () -> Void,
      deliveredNotifications: @escaping @Sendable () async -> [UNNotification],
      removeDeliveredNotifications: @escaping @Sendable ([String]) -> Void,
      removeAllDeliveredNotifications: @escaping @Sendable () -> Void,
      setNotificationCategories: @escaping @Sendable (Set<UNNotificationCategory>) -> Void,
      notificationCategories: @escaping @Sendable () async -> Set<UNNotificationCategory>
    ) {
      self._implementation = .init(
        notificationSettings: .init { notificationSettings },
        setBadgeCount: .init { setBadgeCount },
        requestAuthorization: .init { requestAuthorization },
        delegate: .init(.init(delegate)),
        supportsContentExtensions: .init(supportsContentExtensions),
        add: .init { add },
        pendingNotificationRequests: .init { pendingNotificationRequests },
        removePendingNotificationRequests: .init { removePendingNotificationRequests },
        removeAllPendingNotificationRequests: .init { removeAllPendingNotificationRequests },
        deliveredNotifications: .init { deliveredNotifications },
        removeDeliveredNotifications: .init { removeDeliveredNotifications },
        removeAllDeliveredNotifications: .init { removeAllDeliveredNotifications },
        setNotificationCategories: .init { setNotificationCategories },
        notificationCategories: .init { notificationCategories }
      )
    }
  }

  extension UserNotificationCenter {
    static var system: Self {
      .init(
        notificationSettings: {
          await UNUserNotificationCenter.current().notificationSettings()
        },
        setBadgeCount: { count in
          if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            #if !os(watchOS)
              try await UNUserNotificationCenter.current().setBadgeCount(count)
            #endif
          } else {
            fatalError()
          }
        },
        requestAuthorization: {
          try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
        },
        delegate: (
          { UNUserNotificationCenter.current().delegate },
          { UNUserNotificationCenter.current().delegate = $0 }
        ),
        supportsContentExtensions: UNUserNotificationCenter.current().supportsContentExtensions,
        add: {
          try await UNUserNotificationCenter.current().add($0)
        },
        pendingNotificationRequests: {
          await UNUserNotificationCenter.current().pendingNotificationRequests()
        },
        removePendingNotificationRequests: {
          UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: $0)
        },
        removeAllPendingNotificationRequests: {
          UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        },
        deliveredNotifications: {
          await UNUserNotificationCenter.current().deliveredNotifications()
        },
        removeDeliveredNotifications: {
          UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
        },
        removeAllDeliveredNotifications: {
          UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        },
        setNotificationCategories: {
          UNUserNotificationCenter.current().setNotificationCategories($0)
        },
        notificationCategories: {
          await UNUserNotificationCenter.current().notificationCategories()
        })
    }
  }

  extension UserNotificationCenter {
    static var unimplemented: UserNotificationCenter {
      UserNotificationCenter(
        notificationSettings: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.notificationSettings)"#),
        setBadgeCount: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.setBadgeCount)"#),
        requestAuthorization: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.requestAuthorization)"#),
        delegate: (
          XCTestDynamicOverlay.unimplemented(
            #"@Dependency(\.userNotificationCenter.delegate.get)"#, placeholder: nil),
          { _ in () }
        ),
        supportsContentExtensions: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.supportsContentExtensions)"#),
        add: XCTestDynamicOverlay.unimplemented(#"@Dependency(\.userNotificationCenter.add)"#),
        pendingNotificationRequests: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.pendingNotificationRequests)"#),
        removePendingNotificationRequests: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.removePendingNotificationRequests)"#),
        removeAllPendingNotificationRequests: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.removeAllPendingNotificationRequests)"#),
        deliveredNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\,.userNotificationCenter.deliveredNotifications)"#),
        removeDeliveredNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.removeDeliveredNotifications)"#),
        removeAllDeliveredNotifications: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.userNotificationCenter.removeAllDeliveredNotifications)"#),
        setNotificationCategories: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\,.userNotificationCenter.setNotificationCategories)"#),
        notificationCategories: XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\,.userNotificationCenter.notificationCategories)"#))
    }
  }

#endif

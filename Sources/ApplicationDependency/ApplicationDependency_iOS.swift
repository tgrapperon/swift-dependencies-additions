import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import XCTestDynamicOverlay

#if os(iOS) || os(visionOS)
  @preconcurrency import UIKit

  extension Application: DependencyKey {
    public static var liveValue: Application { .shared }
    public static var testValue: Application { .unimplemented }
    public static var previewValue: Application { .shared }
  }

  extension DependencyValues {
    /// The centralized point of control and coordination for apps running in iOS.
    public var application: Application {
      get { self[Application.self] }
      set { self[Application.self] = newValue }
    }
  }

  /// The centralized point of control and coordination for apps running in iOS.
  public struct Application: Sendable, ConfigurableProxy {
    @_spi(Internals) public var _implementation: Implementation

    /// The delegate of the app object.
    @MainActor
    public var delegate: UIApplicationDelegate? {
      get { _implementation.delegate }
      nonmutating set { _implementation.delegate = newValue }
    }

    /// A Boolean value that controls whether the idle timer is disabled for the app
    @MainActor
    public var isIdleTimerDisabled: Bool {
      get { _implementation.isIdleTimerDisabled }
      nonmutating set { _implementation.isIdleTimerDisabled = newValue }
    }

    /// Returns a Boolean value that indicates whether an app is available to handle a URL scheme.
    @MainActor
    public func canOpenURL(_ url: URL) -> Bool {
      _implementation.canOpenURL(url)
    }

    /// Attempts to asynchronously open the resource at the specified URL.
    @MainActor
    public func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:])
      async
      -> Bool
    {
      await _implementation.open(url, options)
    }

    /// Dispatches an event to the appropriate responder objects in the app.
    @MainActor
    public func sendEvent(_ event: UIEvent) {
      _implementation.sendEvent(event)
    }

    /// Sends an action message identified by the selector to a specified target.
    @MainActor
    public func sendAction(
      _ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?
    )
      -> Bool
    {
      _implementation.sendAction(action, target, sender, event)
    }

    /// Returns the default set of interface orientations to use for the view controllers in the
    /// specified window.
    @MainActor
    public func supportedInterfaceOrientations(for window: UIWindow?) -> UIInterfaceOrientationMask
    {
      _implementation.supportedInterfaceOrientations(window)
    }

    /// The number currently set as the badge of the app icon on the Home screen.
    @MainActor
    public var applicationIconBadgeNumber: Int {
      get { _implementation.applicationIconBadgeNumber }
      nonmutating set { _implementation.applicationIconBadgeNumber = newValue }
    }

    /// A Boolean value that determines whether shaking the device displays the undo-redo user
    /// interface.
    @MainActor
    public var applicationSupportsShakeToEdit: Bool {
      get { _implementation.applicationSupportsShakeToEdit }
      nonmutating set { _implementation.applicationSupportsShakeToEdit = newValue }
    }

    /// The app’s current state, or that of its most active scene.
    @MainActor
    public var applicationState: UIApplication.State {
      _implementation.applicationState
    }

    /// The maximum amount of time remaining for the app to run in the background.
    @MainActor
    public var backgroundTimeRemaining: TimeInterval {
      _implementation.backgroundTimeRemaining
    }

    /// Marks the start of a task with a custom name that should continue if the app enters the
    /// background.
    @MainActor
    public func beginBackgroundTask(
      withName taskName: String? = nil, expirationHandler handler: (() -> Void)? = nil
    ) -> UIBackgroundTaskIdentifier {
      _implementation.beginBackgroundTask(taskName, handler)
    }

    /// Marks the end of a specific long-running background task.
    @MainActor
    public func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
      _implementation.endBackgroundTask(identifier)
    }

    /// Indicates whether the app can refresh content when running in the background.
    @MainActor
    public var backgroundRefreshStatus: UIBackgroundRefreshStatus {
      _implementation.backgroundRefreshStatus
    }

    /// A Boolean value that indicates whether content protection is active.
    @MainActor
    public var isProtectedDataAvailable: Bool {
      _implementation.isProtectedDataAvailable
    }

    /// The layout direction of the user interface.
    @MainActor
    public var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
      _implementation.userInterfaceLayoutDirection
    }

    /// The font sizing option preferred by the user.
    @MainActor
    public var preferredContentSizeCategory: UIContentSizeCategory {
      _implementation.preferredContentSizeCategory
    }

    /// The app’s currently connected scenes.
    @MainActor
    public var connectedScenes: Set<UIScene> {
      _implementation.connectedScenes
    }

    /// The sessions whose scenes are either currently active or archived by the system.
    @MainActor
    public var openSessions: Set<UISceneSession> {
      _implementation.openSessions
    }

    /// A Boolean value that indicates whether the app may display multiple scenes simultaneously.
    @MainActor
    public var supportsMultipleScenes: Bool {
      _implementation.supportsMultipleScenes
    }

    /// Asks the system to activate an existing scene, or create a new scene and associate it with
    /// your app.
    @MainActor
    public func requestSceneSessionActivation(
      _ sceneSession: UISceneSession?, userActivity: NSUserActivity?,
      options: UIScene.ActivationRequestOptions?, errorHandler: ((Error) -> Void)? = nil
    ) {
      _implementation.requestSceneSessionActivation(
        sceneSession, userActivity, options, errorHandler)
    }

    /// Asks the system to dismiss an existing scene and remove it from the app switcher.
    @MainActor
    public func requestSceneSessionDestruction(
      _ sceneSession: UISceneSession, options: UISceneDestructionRequestOptions?,
      errorHandler: ((Error) -> Void)? = nil
    ) {
      _implementation.requestSceneSessionDestruction(
        sceneSession, options, errorHandler)
    }

    /// Asks the system to update any system UI associated with the specified scene.
    @MainActor
    public func requestSceneSessionRefresh(_ sceneSession: UISceneSession) {
      _implementation.requestSceneSessionRefresh(sceneSession)
    }

    /// Registers to receive remote notifications through Apple Push Notification service.
    @MainActor
    public func registerForRemoteNotifications() {
      _implementation.registerForRemoteNotifications()
    }

    /// Unregisters for all remote notifications received through Apple Push Notification service.
    @MainActor
    public func unregisterForRemoteNotifications() {
      _implementation.unregisterForRemoteNotifications()
    }

    /// A Boolean value that indicates whether the app is currently registered for remote
    /// notifications.
    @MainActor
    public var isRegisteredForRemoteNotifications: Bool {
      _implementation.isRegisteredForRemoteNotifications
    }

    /// Tells the app to begin receiving remote-control events.
    @MainActor
    public func beginReceivingRemoteControlEvents() {
      _implementation.beginReceivingRemoteControlEvents()
    }

    /// Tells the app to stop receiving remote-control events.
    @MainActor
    public func endReceivingRemoteControlEvents() {
      _implementation.endReceivingRemoteControlEvents()
    }

    /// The Home screen dynamic quick actions for your app; available on devices that support
    /// 3D Touch.
    @MainActor
    public var shortcutItems: [UIApplicationShortcutItem]? {
      get { _implementation.shortcutItems?.map(\.wrappedValue) }
      nonmutating set {
        _implementation.shortcutItems = newValue?.map(UncheckedSendable.init(wrappedValue:))
      }
    }

    /// A Boolean value that indicates whether the app is allowed to change its icon.
    @MainActor
    public var supportsAlternateIcons: Bool {
      _implementation.supportsAlternateIcons
    }

    /// Changes the icon the system displays for the app.
    @MainActor
    public func setAlternateIconName(_ alternateIconName: String?) async throws {
      try await _implementation.setAlternateIconName(alternateIconName)
    }

    /// The name of the icon the system displays for the app.
    @MainActor
    public var alternateIconName: String? {
      _implementation.alternateIconName
    }

    /// Tells the app that your code is restoring state asynchronously.
    @MainActor
    public func extendStateRestoration() {
      _implementation.extendStateRestoration()
    }

    /// Tells the app that your code has finished any asynchronous state restoration.
    @MainActor
    public func completeStateRestoration() {
      _implementation.completeStateRestoration()
    }

    /// Prevents the app from using the recent snapshot image during the next launch cycle.
    @MainActor
    public func ignoreSnapshotOnNextApplicationLaunch() {
      _implementation.ignoreSnapshotOnNextApplicationLaunch()
    }
  }

  extension Application {
    public struct Implementation: Sendable {
      @MainActorReadWriteProxy public var delegate: UIApplicationDelegate?
      @MainActorReadWriteProxy public var isIdleTimerDisabled: Bool
      @FunctionProxy public var canOpenURL: @MainActor @Sendable (URL) -> Bool
      @FunctionProxy public var open:
        @MainActor @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
      @FunctionProxy public var sendEvent: @MainActor @Sendable (UIEvent) -> Void
      @FunctionProxy public var sendAction:
        @MainActor @Sendable (Selector, Any?, Any?, UIEvent?) -> Bool
      @FunctionProxy public var supportedInterfaceOrientations:
        @MainActor @Sendable (UIWindow?) -> UIInterfaceOrientationMask
      @MainActorReadWriteProxy public var applicationIconBadgeNumber: Int
      @MainActorReadWriteProxy public var applicationSupportsShakeToEdit: Bool
      @MainActorReadOnlyProxy public var applicationState: UIApplication.State
      @MainActorReadOnlyProxy public var backgroundTimeRemaining: TimeInterval
      @FunctionProxy public var beginBackgroundTask:
        @MainActor @Sendable (String?, (() -> Void)?) -> UIBackgroundTaskIdentifier
      @FunctionProxy public var endBackgroundTask:
        @MainActor @Sendable (UIBackgroundTaskIdentifier) -> Void
      @MainActorReadOnlyProxy public var backgroundRefreshStatus: UIBackgroundRefreshStatus
      @MainActorReadOnlyProxy public var isProtectedDataAvailable: Bool
      @MainActorReadOnlyProxy public var userInterfaceLayoutDirection:
        UIUserInterfaceLayoutDirection
      @MainActorReadOnlyProxy public var preferredContentSizeCategory: UIContentSizeCategory
      @MainActorReadOnlyProxy public var connectedScenes: Set<UIScene>
      @MainActorReadOnlyProxy public var openSessions: Set<UISceneSession>
      @MainActorReadOnlyProxy public var supportsMultipleScenes: Bool
      @FunctionProxy public var requestSceneSessionActivation:
        @MainActor @Sendable (
          UISceneSession?, NSUserActivity?, UIScene.ActivationRequestOptions?, ((Error) -> Void)?
        ) -> Void
      @FunctionProxy public var requestSceneSessionDestruction:
        @MainActor @Sendable (UISceneSession, UISceneDestructionRequestOptions?, ((Error) -> Void)?)
          -> Void
      @FunctionProxy public var requestSceneSessionRefresh:
        @MainActor @Sendable (UISceneSession) -> Void
      @FunctionProxy public var registerForRemoteNotifications: @MainActor @Sendable () -> Void
      @FunctionProxy public var unregisterForRemoteNotifications: @MainActor @Sendable () -> Void
      @MainActorReadOnlyProxy public var isRegisteredForRemoteNotifications: Bool
      @FunctionProxy public var beginReceivingRemoteControlEvents: @MainActor @Sendable () -> Void
      @FunctionProxy public var endReceivingRemoteControlEvents: @MainActor @Sendable () -> Void
      @MainActorReadWriteProxy public var shortcutItems:
        [UncheckedSendable<UIApplicationShortcutItem>]?
      @MainActorReadOnlyProxy public var supportsAlternateIcons: Bool
      @FunctionProxy public var setAlternateIconName:
        @MainActor @Sendable (String?) async throws -> Void
      @MainActorReadOnlyProxy public var alternateIconName: String?
      @FunctionProxy public var extendStateRestoration: @MainActor @Sendable () -> Void
      @FunctionProxy public var completeStateRestoration: @MainActor @Sendable () -> Void
      @FunctionProxy public var ignoreSnapshotOnNextApplicationLaunch:
        @MainActor @Sendable () -> Void
    }
  }

  extension Application {
    /// The singleton app instance.
    public static var shared: Application {
      let _implementation = Implementation(
        delegate: .init(
          .init(
            get: { UIApplication.shared.delegate },
            set: { UIApplication.shared.delegate = $0 }
          )),
        isIdleTimerDisabled: .init(
          .init(
            get: { UIApplication.shared.isIdleTimerDisabled },
            set: { UIApplication.shared.isIdleTimerDisabled = $0 }
          )),
        canOpenURL: .init { UIApplication.shared.canOpenURL($0) },
        open: .init { await UIApplication.shared.open($0, options: $1) },
        sendEvent: .init { UIApplication.shared.sendEvent($0) },
        sendAction: .init { UIApplication.shared.sendAction($0, to: $1, from: $2, for: $3) },
        supportedInterfaceOrientations: .init {
          UIApplication.shared.supportedInterfaceOrientations(for: $0)
        },
        applicationIconBadgeNumber: .init(
          .init(
            get: { UIApplication.shared.applicationIconBadgeNumber },
            set: { UIApplication.shared.applicationIconBadgeNumber = $0 }
          )),
        applicationSupportsShakeToEdit: .init(
          .init(
            get: { UIApplication.shared.applicationSupportsShakeToEdit },
            set: { UIApplication.shared.applicationSupportsShakeToEdit = $0 }
          )),
        applicationState: .init { UIApplication.shared.applicationState },
        backgroundTimeRemaining: .init { UIApplication.shared.backgroundTimeRemaining },
        beginBackgroundTask: .init {
          UIApplication.shared.beginBackgroundTask(withName: $0, expirationHandler: $1)
        },
        endBackgroundTask: .init { UIApplication.shared.endBackgroundTask($0) },
        backgroundRefreshStatus: .init { UIApplication.shared.backgroundRefreshStatus },
        isProtectedDataAvailable: .init { UIApplication.shared.isProtectedDataAvailable },
        userInterfaceLayoutDirection: .init { UIApplication.shared.userInterfaceLayoutDirection },
        preferredContentSizeCategory: .init { UIApplication.shared.preferredContentSizeCategory },
        connectedScenes: .init { UIApplication.shared.connectedScenes },
        openSessions: .init { UIApplication.shared.openSessions },
        supportsMultipleScenes: .init { UIApplication.shared.supportsMultipleScenes },
        requestSceneSessionActivation: .init {
          UIApplication.shared.requestSceneSessionActivation(
            $0, userActivity: $1, options: $2, errorHandler: $3)
        },
        requestSceneSessionDestruction: .init {
          UIApplication.shared.requestSceneSessionDestruction($0, options: $1, errorHandler: $2)
        },
        requestSceneSessionRefresh: .init {
          UIApplication.shared.requestSceneSessionRefresh($0)
        },
        registerForRemoteNotifications: .init {
          UIApplication.shared.registerForRemoteNotifications()
        },
        unregisterForRemoteNotifications: .init {
          UIApplication.shared.unregisterForRemoteNotifications()
        },
        isRegisteredForRemoteNotifications: .init {
          UIApplication.shared.isRegisteredForRemoteNotifications
        },
        beginReceivingRemoteControlEvents: .init {
          UIApplication.shared.beginReceivingRemoteControlEvents()
        },
        endReceivingRemoteControlEvents: .init {
          UIApplication.shared.endReceivingRemoteControlEvents()
        },
        shortcutItems: .init(
          .init(
            get: {
              UIApplication.shared.shortcutItems?.map(UncheckedSendable.init(wrappedValue:))
            },
            set: {
              UIApplication.shared.shortcutItems = $0?.map(\.wrappedValue)
            }
          )),
        supportsAlternateIcons: .init { UIApplication.shared.supportsAlternateIcons },
        setAlternateIconName: .init({ try await UIApplication.shared.setAlternateIconName($0) }
        ),
        alternateIconName: .init { UIApplication.shared.alternateIconName },
        extendStateRestoration: .init { UIApplication.shared.extendStateRestoration() },
        completeStateRestoration: .init { UIApplication.shared.completeStateRestoration() },
        ignoreSnapshotOnNextApplicationLaunch: .init {
          UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        }
      )
      return Application(_implementation: _implementation)
    }
  }

  extension Application {
    public static var unimplemented: Application {
      let _implementation = Implementation(
        delegate: .unimplemented(
          #"@Dependency(\.application.delegate.get)"#,
          placeholder: nil),
        isIdleTimerDisabled: .unimplemented(
          #"@Dependency(\.application.isIdleTimerDisabled.get)"#),
        canOpenURL: .unimplemented(
          #"@Dependency(\.application.canOpenURL)"#),
        open: .unimplemented(
          #"@Dependency(\.application.open)"#),
        sendEvent: .unimplemented(
          #"@Dependency(\.application.sendEvent)"#),
        sendAction: .unimplemented(
          #"@Dependency(\.application.sendAction)"#),
        supportedInterfaceOrientations: .unimplemented(
          #"@Dependency(\.application.supportedInterfaceOrientations)"#,
          placeholder: { _ in UIInterfaceOrientationMask() }),
        applicationIconBadgeNumber: .unimplemented(
          #"@Dependency(\.application.applicationIconBadgeNumber.get)"#),
        applicationSupportsShakeToEdit: .unimplemented(
          #"@Dependency(\.application.applicationSupportsShakeToEdit.get)"#),
        applicationState: .unimplemented(
          #"@Dependency(\.application.applicationState)"#,
          placeholder: UIApplication.State.inactive),
        backgroundTimeRemaining: .unimplemented(
          #"@Dependency(\.application.backgroundTimeRemaining)"#),
        beginBackgroundTask: .unimplemented(
          #"@Dependency(\.application.beginBackgroundTask)"#,
          placeholder: { _, _ in .invalid }),
        endBackgroundTask: .unimplemented(
          #"@Dependency(\.application.endBackgroundTask)"#),
        backgroundRefreshStatus: .unimplemented(
          #"@Dependency(\.application.backgroundRefreshStatus)"#,
          placeholder: UIBackgroundRefreshStatus.denied),
        isProtectedDataAvailable: .unimplemented(
          #"@Dependency(\.application.isProtectedDataAvailable)"#),
        userInterfaceLayoutDirection: .unimplemented(
          #"@Dependency(\.application.userInterfaceLayoutDirection)"#,
          placeholder: UIUserInterfaceLayoutDirection.leftToRight),
        preferredContentSizeCategory: .unimplemented(
          #"@Dependency(\.application.preferredContentSizeCategory)"#,
          placeholder: UIContentSizeCategory.unspecified),
        connectedScenes: .unimplemented(
          #"@Dependency(\.application.connectedScenes)"#),
        openSessions: .unimplemented(
          #"@Dependency(\.application.openSessions)"#),
        supportsMultipleScenes: .unimplemented(
          #"@Dependency(\.application.supportsMultipleScenes)"#),
        requestSceneSessionActivation: .unimplemented(
          #"@Dependency(\.application.requestSceneSessionActivation)"#),
        requestSceneSessionDestruction: .unimplemented(
          #"@Dependency(\.application.requestSceneSessionDestruction)"#),
        requestSceneSessionRefresh: .unimplemented(
          #"@Dependency(\.application.requestSceneSessionRefresh)"#),
        registerForRemoteNotifications: .unimplemented(
          #"@Dependency(\.application.registerForRemoteNotifications)"#),
        unregisterForRemoteNotifications: .unimplemented(
          #"@Dependency(\.application.unregisterForRemoteNotifications)"#),
        isRegisteredForRemoteNotifications: .unimplemented(
          #"@Dependency(\.application.isRegisteredForRemoteNotifications)"#),
        beginReceivingRemoteControlEvents: .unimplemented(
          #"@Dependency(\.application.beginReceivingRemoteControlEvents)"#),
        endReceivingRemoteControlEvents: .unimplemented(
          #"@Dependency(\.application.endReceivingRemoteControlEvents)"#),
        shortcutItems: .unimplemented(
          #"@Dependency(\.application.shortcutItems.get)"#,
          placeholder: nil),
        supportsAlternateIcons: .unimplemented(
          #"@Dependency(\.application.supportsAlternateIcons)"#),
        setAlternateIconName:
          .unimplemented(#"@Dependency(\.application.setAlternateIconName)"#),
        alternateIconName: .unimplemented(
          #"@Dependency(\.application.alternateIconName)"#,
          placeholder: nil),
        extendStateRestoration: .unimplemented(
          #"@Dependency(\.application.extendStateRestoration)"#),
        completeStateRestoration: .unimplemented(
          #"@Dependency(\.application.completeStateRestoration)"#),
        ignoreSnapshotOnNextApplicationLaunch: .unimplemented(
          #"@Dependency(\.application.ignoreSnapshotOnNextApplicationLaunch)"#)
      )
      return Application(_implementation: _implementation)
    }
  }

#endif

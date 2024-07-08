#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  // WIP - Should we ship a bunch of common notifications?
  import Dependencies

  extension Notifications {
    public enum System {}
    public enum User {}
  }

  extension Notifications {
    public typealias NotificationOf<Value> = _TaggedNotificationOf<User, Value>
    public typealias MainActorNotificationOf<Value> = _TaggedMainActorNotificationOf<User, Value>
    public typealias SystemNotificationOf<Value> = _TaggedNotificationOf<System, Value>
    public typealias MainActorSystemNotificationOf<Value> = _TaggedMainActorNotificationOf<
      System, Value
    >
  }

  #if canImport(UIKit.UIApplication) && !os(watchOS)
    import UIKit.UIApplication
    extension Notifications {
      /// A notification that posts when a person takes a screenshot on the device.
      @MainActor
      public var userDidTakeScreenshot: SystemNotificationOf<Void> {
        .init(UIApplication.userDidTakeScreenshotNotification)
      }
      /// A notification that posts shortly before an app leaves the background state on its way to
      /// becoming the active app.
      @MainActor
      public var applicationWillEnterForeground: SystemNotificationOf<Void> {
        .init(UIApplication.willEnterForegroundNotification)
      }
      /// A notification that posts when the app enters the background.
      @MainActor
      public var applicationDidEnterBackground: SystemNotificationOf<Void> {
        .init(UIApplication.didEnterBackgroundNotification)
      }
    }
  #endif

  #if canImport(UIKit.UIScene) && !os(watchOS)
    import UIKit.UIScene
    extension Notifications {
      /// A notification that indicates that a scene is about to begin running in the foreground and
      /// become visible to the user.
      @MainActor
      public var sceneWillEnterForeground: SystemNotificationOf<UIScene> {
        let name = UIScene.willEnterForegroundNotification
        return .init(name) {
          $0.object as? UIScene
        } embed: {
          $1.object = $0
        }
      }
    }
  #endif

  #if canImport(UIKit.UIDevice) && !os(watchOS) && !os(tvOS)
    import UIKit.UIDevice
    import DeviceDependency
    extension Notifications {
      /// A notification that posts when the battery level changes.
      @MainActor
      public var batteryLevelDidChange: MainActorSystemNotificationOf<Float> {
        .init(UIDevice.batteryLevelDidChangeNotification) { _ in
          @Dependency(\.device.batteryLevel) var batteryLevel
          return batteryLevel
        } placeholder: {
          @Dependency(\.device.batteryLevel) var batteryLevel
          return batteryLevel
        }
      }

      /// A notification that posts when the battery state changes.
      @MainActor
      public var batteryStateDidChange: MainActorSystemNotificationOf<UIDevice.BatteryState> {
        return .init(UIDevice.batteryStateDidChangeNotification) { _ in
          @Dependency(\.device.batteryState) var batteryState
          return batteryState
        } placeholder: {
          @Dependency(\.device.batteryState) var batteryState
          return batteryState
        }
      }
    }
  #endif
#endif

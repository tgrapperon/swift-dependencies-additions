// WIP - Should we ship a bunch of common notifications?
import Dependencies

#if canImport(UIKit.UIApplication)
  import UIKit.UIApplication
  extension Notifications {
    /// A notification that posts when a person takes a screenshot on the device.
    @MainActor
    public var userDidTakeScreenshot: NotificationOf<Void> {
      .init(UIApplication.userDidTakeScreenshotNotification)
    }
    @MainActor
    public var applicationWillEnterForeground: NotificationOf<Void> {
      .init(UIApplication.willEnterForegroundNotification)
    }
    @MainActor
    public var applicationDidEnterBackground: NotificationOf<Void> {
      .init(UIApplication.didEnterBackgroundNotification)
    }
    
    
  }
#endif

#if canImport(UIKit.UIScene)
  import UIKit.UIScene
  extension Notifications {
    /// A notification that indicates that a scene is about to begin running in the foreground and
    /// become visible to the user.
    @MainActor
    public var sceneWillEnterForeground: NotificationOf<UIScene> {
      let name = UIScene.willEnterForegroundNotification
      return .init(name) {
        $0.object as? UIScene
      } embed: {
        $1.object = $0
      }
    }
  }
#endif

#if canImport(UIKit.UIDevice)
import UIKit.UIDevice
import DeviceDependency
extension Notifications {
  /// A notification that posts when the battery level changes.
  @MainActor
  public var batteryLevelDidChange: MainActorNotificationOf<Float> {
    .init(UIDevice.batteryLevelDidChangeNotification) { _ in
      @Dependency(\.device.batteryLevel) var batteryLevel;
      return batteryLevel
    }
  }
  
  /// A notification that posts when the battery level changes.
  @MainActor
  public var batteryStateDidChange: MainActorNotificationOf<UIDevice.BatteryState> {
    return .init(UIDevice.batteryStateDidChangeNotification) { _ in
      @Dependency(\.device.batteryState) var batteryState;
      return batteryState
    }
  }
}
#endif

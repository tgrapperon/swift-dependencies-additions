#if canImport(UIKit.UIApplication)
  import UIKit.UIApplication
  extension Notifications {
    /// A notification that posts when a person takes a screenshot on the device.
    @MainActor
    public var userDidTakeScreenshot: ObservationOf<Void> {
      .init(UIApplication.userDidTakeScreenshotNotification) { _ in
        ()
      } notify: {
        .init(name: UIApplication.userDidTakeScreenshotNotification)
      }
    }
    @MainActor
    public var applicationWillEnterForeground: ObservationOf<Void> {
      .init(UIApplication.willEnterForegroundNotification) { _ in
        ()
      } notify: {
        .init(name: UIApplication.willEnterForegroundNotification)
      }
    }
    @MainActor
    public var applicationDidEnterBackground: ObservationOf<Void> {
      .init(UIApplication.didEnterBackgroundNotification) { _ in
        ()
      } notify: {
        .init(name: UIApplication.didEnterBackgroundNotification)
      }
    }
  }
#endif

#if canImport(UIKit.UIScene)
  import UIKit.UIScene
  extension Notifications {
    /// A notification that indicates that a scene is about to begin running in the foreground and
    /// become visible to the user.
    @MainActor
    public var sceneWillEnterForeground: ObservationOf<UIScene> {
      .init(UIScene.willEnterForegroundNotification) {
        $0.object as! UIScene
      } notify: {
        .init(name: UIScene.willEnterForegroundNotification, object: $0)
      }
    }
  }
#endif

// …

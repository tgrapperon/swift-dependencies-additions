import Foundation
import NotificationCenterDependency

extension NotificationCenter.Dependency {
  func streamOf<Value>(_ notification: Notifications.NotificationOf<Value>, file: StaticString, line: UInt)
    -> Notifications.StreamOf<Value>
  {
    Notifications.StreamOf<Value>(notification) { value, file, line in
      var nsNotification = notification.notification
      notification.embed(value, into: &nsNotification)
      self.post(
        name: nsNotification.name,
        object: nsNotification.object as AnyObject,
        userInfo: nsNotification.userInfo,
        file: file,
        line: line
      )
    } stream: {
      self.notifications(
        named: notification.name,
        object: notification.object?.wrappedValue,
        file: file,
        line: line
      )
      .compactMap {
        notification.extract(from: $0)
      }
      .eraseToStream()
    }
  }
}

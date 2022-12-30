import Foundation
import Dependencies
public protocol NotificationCenterProtocol: Sendable {
  func post(_ notification: Notification)
  subscript<Value>(notification: Notifications.NotificationOf<Value>) -> Notifications.StreamOf<Value> { get }
  // The subscript for @dynamicMemberLookup needs to be declared at the protocol
  // level or it crashes when trying to build of testing
  // TODO: Report this
  subscript<Value>(dynamicMember keyPath: KeyPath<Notifications, Notifications.NotificationOf<Value>>) -> Notifications.StreamOf<Value> { get }
}

extension NotificationCenterProtocol {
  public subscript<Value>(dynamicMember keyPath: KeyPath<Notifications, Notifications.NotificationOf<Value>>) -> Notifications.StreamOf<Value> {
    self[Notifications()[keyPath: keyPath]]
  }
}

extension Notifications {
  public struct NotificationCenter: Sendable {
    
    var _post: @Sendable (_ notification: Notification) -> Void
    var _stream: @Sendable (Any) -> StreamOf<Any>
    
    init(
      post: @escaping @Sendable (Notification) -> Void,
      stream: @escaping @Sendable (Any) -> StreamOf<Any>) {
      self._post = post
      self._stream = stream
    }
    
    func stream<Value>(_ notification: NotificationOf<Value>) -> StreamOf<Value> {
      _stream(notification) as! StreamOf<Value>
    }
  }
}

//extension Notifications {
//  func test() {
//    NotificationOf(<#T##name: Notification.Name##Notification.Name#>, object: <#T##NSObject?#>)
//  }
//}

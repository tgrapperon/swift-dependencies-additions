import Foundation
import Dependencies

// TODO: Convert to protocol witness?

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


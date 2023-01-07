import Combine
import Dependencies
import Foundation
import SwiftUI

// TODO: Explore observing any DynamicProperty instead of only `Environment`

// Trying to make this a `DynamicProperty` itself to automatically udpate the value
// at `udpate()` doesn't work as we don't have a guarantee that an internal `@Environment`
// value would have received its udpate before this value and expose the latest value.
// Any attempt to defer the call risks getting out of the `update`/`body` cycle and raise
// a runtime warning.
extension Dependency {
  @MainActor
  @propertyWrapper
  public struct Environment {
    @Dependencies.Dependency(\._swiftuiEnvironment) var environment

    let keyPath: KeyPath<EnvironmentValues, Value>
    let id: AnyHashable?

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>, id: AnyHashable? = nil) {
      self.keyPath = keyPath
      self.id = id
    }

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>, id: Any.Type) {
      self.init(keyPath, id: ObjectIdentifier(id))
    }

    public var wrappedValue: Value? {
      self.environment.value(self.keyPath, id: self.id)
    }
    public var projectedValue: AsyncStream<Value?> {
      self.environment.stream(self.keyPath, id: self.id)
    }
  }
}

extension DependencyValues {
  // This environment value is internal, accessed through `@Dependency.Environment(\…)`
  var _swiftuiEnvironment: SwiftUIEnvironment {
    get { self[SwiftUIEnvironment.self] }
    set { self[SwiftUIEnvironment.self] = newValue }
  }
}
extension EnvironmentValues {
  var _swiftuiEnvironment: SwiftUIEnvironment {
    get { self[SwiftUIEnvironment.self] }
    set { self[SwiftUIEnvironment.self] = newValue }
  }
}

@MainActor
final class SwiftUIEnvironment: Sendable, EnvironmentKey, DependencyKey {
  struct Key: Hashable, @unchecked Sendable {
    let id: AnyHashable?
    let keypath: PartialKeyPath<EnvironmentValues>
    init(id: AnyHashable? = nil, keypath: PartialKeyPath<EnvironmentValues>) {
      self.id = id
      self.keypath = keypath
    }
  }

  public nonisolated static var defaultValue: SwiftUIEnvironment { .shared }
  public nonisolated static var liveValue: SwiftUIEnvironment { .shared }
  public nonisolated static var testValue: SwiftUIEnvironment { .shared }

  internal static let shared = SwiftUIEnvironment()

  @Published private var dependencies = [Key: Any]()

  init() {}

  func update<ID: Hashable, Value>(
    _ value: Value?,
    keyPath: KeyPath<EnvironmentValues, Value>,
    id: ID? = String?.none
  ) {
    self.dependencies[Key(id: id, keypath: keyPath)] = value
  }

  func value<Value>(_ keyPath: KeyPath<EnvironmentValues, Value>, id: AnyHashable?) -> Value? {
    self.dependencies[Key(id: id, keypath: keyPath)] as? Value
  }

  func stream<Value>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: AnyHashable? = nil
  )
    -> AsyncStream<Value?>
  {
    AsyncStream(Value?.self) { continuation in
      let key = Key(id: id, keypath: keyPath)
      let cancellable = UncheckedSendable(
        self.$dependencies
          .map { $0[key] as? Value }
          // We still need to remove duplicates as `dependencies` can be updated
          // multiple types by different observed environment values.
          .removeDuplicates(by: isDuplicate(v1:v2:))
          .sink { continuation.yield($0) }
      )
      continuation.onTermination = { _ in
        cancellable.wrappedValue.cancel()
      }
    }
  }
}

// TODO: Find a better name
extension View {
  public func observeEnvironmentAsDependency<Value>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: AnyHashable? = nil
  ) -> some View {
    self.modifier(EnvironmentalDependencyModifier(keyPath: keyPath, id: id))
  }

  public func observeEnvironmentAsDependency<Value>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: Any.Type
  ) -> some View {
    self.modifier(EnvironmentalDependencyModifier(keyPath: keyPath, id: ObjectIdentifier(id)))
  }
}

struct EnvironmentalDependencyModifier<ID: Hashable, Value>: ViewModifier {
  final class Values {
    let currentValue: CurrentValueSubject<Value?, Never> = .init(nil)
    private(set) lazy var publisher: AnyPublisher<Value?, Never> = self.currentValue
      .removeDuplicates(by: isDuplicate(v1:v2:))
      .eraseToAnyPublisher()
  }

  let _environmentValue: Environment<Value>
  let id: ID?
  let keyPath: KeyPath<EnvironmentValues, Value>

  @Environment(\._swiftuiEnvironment) var dependencies
  @State var values = Values()

  init(keyPath: KeyPath<EnvironmentValues, Value>, id: ID?) {
    self._environmentValue = .init(keyPath)
    self.keyPath = keyPath
    self.id = id
  }

  func body(content: Content) -> some View {
    let _ = self.values.currentValue.send(self._environmentValue.wrappedValue)
    content
      .onReceive(self.values.publisher) {
        self.dependencies.update($0, keyPath: self.keyPath, id: self.id)
      }
  }
}

private func isDuplicate<V>(v1: V?, v2: V?) -> Bool {
  if let v1 = v1 as? any Equatable, let v2 = v2 as? any Equatable {
    return v1.isEqual(to: v2)
  } else {
    var v1 = v1
    var v2 = v2
    return memcmp(&v1, &v2, MemoryLayout.size(ofValue: v1)) == 0
  }
}

extension Equatable {
  fileprivate func isEqual(to other: any Equatable) -> Bool {
    if let other = other as? Self {
      return other == self
    } else {
      return false
    }
  }
}

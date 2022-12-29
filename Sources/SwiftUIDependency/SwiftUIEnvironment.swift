import Combine
import Dependencies
import Foundation
import SwiftUI

// TODO: Add @Dependency.Environment with automatic identification

// In SwiftUI, one adds `.observe(\.environmentValue)` or `.observe(\.environmentValue, id: "A")`.
// Then anywhere:
//
// @Dependency(\.environment) var environment // A SwiftUIEnvironment value, where one
// can extract a value or a stream using dynamic lookup:
// @Dependency(\.environment.colorScheme) var colorScheme (id == String?.none)
// @Dependency(\.environment["some"].colorScheme) var colorScheme (id == "some")
// @Dependency(\.environment.streams.colorScheme) var colorSchemes (AsyncStream<ColorScheme?>)
// @Dependency(\.environment["some"].streams.colorScheme) var colorSchemes (AsyncStream<ColorScheme?>)

// TODO: `stream` refactor so `stream` appears before the `id` subscript
// TODO: Rename `id` as `tag`?
// TODO: Explore observing any DynamicProperty

extension DependencyValues {
  public var environment: SwiftUIEnvironment {
    get { self[SwiftUIEnvironment.self] }
    set { self[SwiftUIEnvironment.self] = newValue }
  }
}

@MainActor
@dynamicMemberLookup
public final class SwiftUIEnvironment: Sendable, EnvironmentKey, DependencyKey {
  public nonisolated static var defaultValue: SwiftUIEnvironment { .shared }
  public nonisolated static var liveValue: SwiftUIEnvironment { .shared }
  public nonisolated static var testValue: SwiftUIEnvironment { .shared }

  internal static let shared = SwiftUIEnvironment()

  @Published private var dependencies = [Key: Any]()

  init() {}

  internal func update<ID: Hashable, Value>(
    _ value: Value?,
    keyPath: KeyPath<EnvironmentValues, Value>,
    id: ID? = String?.none
  ) {
    self.dependencies[Key(id: id, keypath: keyPath)] = value
  }

  // Value with `ID == String?.none`
  public subscript<Value>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>) -> Value? {
    self.dependencies[Key(id: String?.none, keypath: keyPath)] as? Value
  }

  // Identified proxy
  public nonisolated subscript(id: AnyHashable) -> Identified {
    Identified(id: id, swiftuiEnvironment: self)
  }

  // Streams
  public nonisolated var streams: Streams {
    .init(swiftuiEnvironment: self)
  }

  // Stream
  public func stream<Value: Sendable, ID: Hashable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: ID? = String?.none
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

extension SwiftUIEnvironment {
  struct Key: Hashable {
    let id: AnyHashable?
    let keypath: PartialKeyPath<EnvironmentValues>
    init(id: AnyHashable? = nil, keypath: PartialKeyPath<EnvironmentValues>) {
      self.id = id
      self.keypath = keypath
    }
  }
}

extension SwiftUIEnvironment {
  @MainActor
  @dynamicMemberLookup
  public struct Streams {
    let swiftuiEnvironment: SwiftUIEnvironment
    public subscript<Value: Sendable>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>)
      -> AsyncStream<Value?>
    {
      self.swiftuiEnvironment.stream(keyPath)
    }
  }
}

extension SwiftUIEnvironment {
  // A proxy for identified values. Created using the `id` subscript on `SwiftUIEnvironment`.
  @MainActor
  @dynamicMemberLookup
  public struct Identified {
    let id: AnyHashable
    let swiftuiEnvironment: SwiftUIEnvironment

    // Value
    public subscript<Value>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>) -> Value? {
      self.swiftuiEnvironment.dependencies[Key(id: self.id, keypath: keyPath)] as? Value
    }

    // Streams
    public var streams: Streams {
      Streams(id: self.id, swiftuiEnvironment: self.swiftuiEnvironment)
    }

    @MainActor
    @dynamicMemberLookup
    public struct Streams {
      let id: AnyHashable
      let swiftuiEnvironment: SwiftUIEnvironment
      public subscript<Value: Sendable>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>)
        -> AsyncStream<Value?>
      {
        self.swiftuiEnvironment.stream(keyPath, id: self.id)
      }
    }
  }
}

extension View {
  public func observeEnvironmentAsDependency<Value: Sendable, ID: Hashable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: ID? = String?.none
  ) -> some View {
    self.modifier(EnvironmentalDependencyModifier(keyPath: keyPath, id: id))
  }
}

extension EnvironmentValues {
  var _swiftuiEnvironment: SwiftUIEnvironment {
    get { self[SwiftUIEnvironment.self] }
    set { self[SwiftUIEnvironment.self] = newValue }
  }
}

struct EnvironmentalDependencyModifier<ID: Hashable, Value: Sendable>: ViewModifier {
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

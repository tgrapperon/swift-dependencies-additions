import Combine
import Dependencies
import Foundation
import SwiftUI

// In SwiftUI, one adds `.observe(\.environmentValue)` or `.observe(\.environmentValue, id: "A")`.
// Then anywhere:
//
// @Dependency(\.environment) var environment // An EnvironmentalDependencies value, where one
// can extract a value or a stream using dynamic lookup:
// @Dependency(\.environment.colorScheme) var colorScheme (id == String?.none)
// @Dependency(\.environment["some"].colorScheme) var colorScheme (id == "some")
// @Dependency(\.environment.streams.colorScheme) var colorSchemes (AsyncStream<ColorScheme?>)
// @Dependency(\.environment["some"].streams.colorScheme) var colorSchemes (AsyncStream<ColorScheme?>)

// TODO: Rename `id` as `tag`?

extension DependencyValues {
  public var environment: EnvironmentalDependencies {
    get { self[EnvironmentalDependencies.self] }
    set { self[EnvironmentalDependencies.self] = newValue }
  }
}

@MainActor
@dynamicMemberLookup
public final class EnvironmentalDependencies: Sendable, EnvironmentKey, DependencyKey {
  struct Key: Hashable {
    let id: AnyHashable?
    let keypath: PartialKeyPath<EnvironmentValues>
    init(id: AnyHashable? = nil, keypath: PartialKeyPath<EnvironmentValues>) {
      self.id = id
      self.keypath = keypath
    }
  }

  @MainActor
  @dynamicMemberLookup
  public struct Streams {
    let environmentalDependencies: EnvironmentalDependencies
    public subscript<Value: Sendable>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>)
      -> AsyncStream<Value?>
    {
      self.environmentalDependencies.stream(keyPath)
    }
  }

  // A proxy to identified values. Created using the `id` subscript on `EnvironmentDependencies`.
  @MainActor
  @dynamicMemberLookup
  public struct Identified<ID: Hashable> {
    let id: ID
    let environmentalDependencies: EnvironmentalDependencies
    // Value
    public subscript<Value>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>) -> Value? {
      environmentalDependencies.dependencies[Key(id: id, keypath: keyPath)] as? Value
    }
    // Streams
    public var streams: Streams {
      .init(id: id, environmentalDependencies: environmentalDependencies)
    }

    @MainActor
    @dynamicMemberLookup
    public struct Streams {
      let id: ID
      let environmentalDependencies: EnvironmentalDependencies
      public subscript<Value: Sendable>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>)
        -> AsyncStream<Value?>
      {
        self.environmentalDependencies.stream(keyPath, id: id)
      }
    }
  }

  nonisolated public static var defaultValue: EnvironmentalDependencies { .shared }
  nonisolated public static var liveValue: EnvironmentalDependencies { .shared }
  nonisolated public static var testValue: EnvironmentalDependencies { .shared }

  private static let shared = EnvironmentalDependencies()

  @Published private var dependencies = [Key: Any]()

  init() {}

  // Value with `ID == String?.none`
  public subscript<Value>(dynamicMember keyPath: KeyPath<EnvironmentValues, Value>) -> Value? {
    self.dependencies[Key(id: String?.none, keypath: keyPath)] as? Value
  }
  // Identified proxy
  public subscript<ID: Hashable>(id: ID) -> Identified<ID> {
    Identified(id: id, environmentalDependencies: self)
  }

  // Streams
  public var streams: Streams {
    .init(environmentalDependencies: self)
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
          .compactMap { $0[key] as! Value? }
          .sink {
            continuation.yield($0)
          }
      )
      continuation.onTermination = { _ in
        cancellable.wrappedValue.cancel()
      }
    }
  }

  fileprivate func update<ID: Hashable, Value>(
    _ value: Value?, keyPath: KeyPath<EnvironmentValues, Value>, id: ID? = String?.none
  ) {
    self.dependencies[Key(id: id, keypath: keyPath)] = value
  }
}

extension View {
  public func observe<Value: Sendable, ID: Hashable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>, id: ID? = String?.none
  )
    -> some View
  {
    self.modifier(EnvironmentalDependencyModifier(keyPath: keyPath, id: id))
  }
}

extension EnvironmentValues {
  var _environmentalDependencies: EnvironmentalDependencies {
    get { self[EnvironmentalDependencies.self] }
    set { self[EnvironmentalDependencies.self] = newValue }
  }
}

struct EnvironmentalDependencyModifier<ID: Hashable, Value: Sendable>: ViewModifier {
  final class Values {
    let currentValue: CurrentValueSubject<Value?, Never> = .init(nil)
    private(set) lazy var publisher: AnyPublisher<Value?, Never> = self.currentValue
      .removeDuplicates { v1, v2 in
        if let v1 = v1 as? any Equatable, let v2 = v2 as? any Equatable {
          return v1.isEqual(to: v2)
        } else {
          var v1 = v1
          var v2 = v2
          return memcmp(&v1, &v2, MemoryLayout.size(ofValue: v1)) == 0
        }
      }
      .eraseToAnyPublisher()
  }

  let _environmentValue: Environment<Value>
  let id: ID?
  let keyPath: KeyPath<EnvironmentValues, Value>

  @Environment(\._environmentalDependencies) var dependencies
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

extension Equatable {
  fileprivate func isEqual(to other: any Equatable) -> Bool {
    if let other = other as? Self {
      return other == self
    } else {
      return false
    }
  }
}

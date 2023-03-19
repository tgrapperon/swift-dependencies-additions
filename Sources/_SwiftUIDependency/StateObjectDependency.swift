#if canImport(SwiftUI)
  import Dependencies
  import SwiftUI

  @available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
  extension StateObject {
    /// A property wrapper type that instantiates an observable object.
    ///
    /// SwiftUI's `StateObject` uses an autoclosure in its initializer. This function is evaluated
    /// privately (and only once during the lifetime of the `View`). As a result, dependencies
    /// surrounding this property wrapper's initializer (or the initializer of the `View` that
    /// contains it) are reset to their defaults by the time the closure is evaluted.
    ///
    /// This property wrapper fixes this issue while preserving SwiftUI's `StateObject` behavior.
    /// You use it in the same fashion you would use SwiftUI's `StateObject`.
    ///
    /// ```swift
    /// struct MyView: View {
    ///   @StateObject.Dependency var model: Model
    ///   var body: some View {
    ///     …
    ///   }
    /// }
    /// ```
    @propertyWrapper
    public struct Dependency: DynamicProperty {
      @StateObject var object: ObjectType
      /// Creates a new state object with an initial wrapped value.
      public init(wrappedValue: @escaping @autoclosure () -> ObjectType) {
        self._object = withEscapedDependencies { continuation in
            StateObject(wrappedValue: {
              continuation.yield {
                wrappedValue()
              }
            }())
        }
      }
      /// The underlying value referenced by the state object.
      public var wrappedValue: ObjectType {
        object
      }
      /// A projection of the state object that creates bindings to its properties.
      public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        $object
      }
    }
  }
#endif

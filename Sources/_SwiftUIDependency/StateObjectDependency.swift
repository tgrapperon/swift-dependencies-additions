#if canImport(SwiftUI)
  import Dependencies
  import SwiftUI

  @available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
  extension StateObject {
    /// A property wrapper type that instantiates an observable object.
    ///
    // TODO: Explain why
    @propertyWrapper
    public struct Dependency: DynamicProperty {
      @StateObject var object: ObjectType
      /// Creates a new state object with an initial wrapped value.
      public init(wrappedValue: @escaping @autoclosure () -> ObjectType) {
        // We capture the current dependencies in the escaping autoclosure.
        // We can't use withEscapedDependencies because it would require to capture
        // `self` in its block before `self` is initialized.
        @Dependencies.Dependency(\.self) var dependencies
        self._object = .init(
          wrappedValue: {
            withDependencies {
              $0 = dependencies
            } operation: {
              wrappedValue()
            }
          }())
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

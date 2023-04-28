import Dependencies

/// A protocol that allows a type to parametrize the implementation of its properties and methods.
///
/// This contruct uses the ``ReadWriteProxy``, ``ReadOnlyProxy``, ``FunctionProxy`` property
/// wrappers (as well as their `MainActor` counterparts: ``MainActorReadWriteProxy`` and
/// ``MainActorReadOnlyProxy``) to:
///
/// - Defer the live implementation of your dependency to an external value
/// - Scope the possible overrides behind their projected value to make clear that a given
/// property or method is not meant to be overridden in live contexts.
/// - Gather all the implementations into a standalone type and re-expose them as functions with
/// labelled arguments.
///
/// To sum up, your ``ConfigurableProxy`` dependendency looks like a plain struct, with properties
/// and methods with arguments, but you can override the implementation of any method/property using
/// the `$` prefix if you're using the same names for the properties/methods and their
/// implementation:
///
/// ```swift
/// public struct Manager: ConfigurableProxy, Sendable {
///   public struct Implementation {
///     @ReadOnlyProxy var maxLimit: Int
///     @FunctionProxy var fetchValues: (UUID) async -> [Value]
///   }
///
///   @_spi(Hidden) public var _implementation: Implementation
///
///   // Re-expose implemented properties and methods:
///   public var maxLimit: Int {
///     self._implementation.maxLimit
///   }
///   public func fetchValues(for id: UUID) async -> [Value] {
///     await self._implementation.fetchValues(id)
///   }
/// }
/// // And then:
/// withDependencies {
///   $0.manager.$maxLimit = 4
///   $0.manager.$fetchValues = { _ in [] }
/// } operation: {
///   …
/// }
/// ```
@dynamicMemberLookup
public protocol ConfigurableProxy {
  associatedtype Implementation
  /// If you annotate this property with some `@_spi(SomeArbitraryLabel)`, the value may be hidden
  /// from external modules while still be visible by the compiler to fulfil the protocol
  /// requirements. This allows to hide this requirement from Xcode autocompletion most of the
  /// time.
  var _implementation: Implementation { get set }
  /// A default implementation is provided.
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadWriteProxy<Value>>)
    -> ReadWriteBinding<Value>
  { get set }

  /// A default implementation is provided.
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>)
    -> @Sendable () -> Value
  { get set }

  /// A default implementation is provided.
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>)
    -> Value
  { get set }

  /// A default implementation is provided.
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, FunctionProxy<Value>>)
    -> Value
  { get set }

  /// A default implementation is provided.
  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadWriteProxy<Value>>
  )
    -> MainActorReadWriteBinding<Value>
  { get set }

  /// A default implementation is provided.
  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  )
    -> @MainActor @Sendable () -> Value
  { get set }

  /// A default implementation is provided.
  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  )
    -> Value
  { @MainActor get set }
}

extension ConfigurableProxy {
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, ReadWriteProxy<Value>>
  )
    -> ReadWriteBinding<Value>
  {
    get { self._implementation[keyPath: keyPath].binding }
    set { self._implementation[keyPath: keyPath].binding = newValue }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>
  ) -> @Sendable () -> Value {
    get { self._implementation[keyPath: keyPath]._value }
    set { self._implementation[keyPath: keyPath]._value = newValue }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>
  ) -> Value {
    get { self._implementation[keyPath: keyPath]._value() }
    set { self._implementation[keyPath: keyPath]._value = { newValue } }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, FunctionProxy<Value>>
  ) -> Value {
    get { self._implementation[keyPath: keyPath]._value() }
    set { self._implementation[keyPath: keyPath]._value = { newValue } }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadWriteProxy<Value>>
  )
    -> MainActorReadWriteBinding<Value>
  {
    get { self._implementation[keyPath: keyPath].binding }
    set { self._implementation[keyPath: keyPath].binding = newValue }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  ) -> @MainActor @Sendable () -> Value {
    get { self._implementation[keyPath: keyPath]._value }
    set { self._implementation[keyPath: keyPath]._value = newValue }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  ) -> Value {
    @MainActor get { self._implementation[keyPath: keyPath]._value() }
    set { self._implementation[keyPath: keyPath]._value = { newValue } }
  }
}

/// A value that describes a bidirectional binding.
///
/// You use this type to mock the storage of ``ReadWriteProxy`` properties:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = ReadWriteBinding(isBatteryMonitoringEnabled)
/// } operation { … }
/// ```
/// This allows to inspect and control dependencies exposing writable properties.
/// See ``MainActorReadWriteBinding`` for a version adapted to `MainActor` dependencies.
public struct ReadWriteBinding<Value>: Sendable {
  let get: @Sendable () -> Value
  let set: @Sendable (Value) -> Void

  /// Initializes a ``ReadWriteProxy`` from a pair for `get` and `set` closures.
  public init(get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
    self.get = get
    self.set = set
  }

  @available(*, deprecated, message: "Use the two-arguments `get:set:` variant.")
  @_spi(Internals) public init(_ getSet: (@Sendable () -> Value, @Sendable (Value) -> Void)) {
    self.get = getSet.0
    self.set = getSet.1
  }

  /// Initializes a ``ReadWriteProxy`` from a ``ProxyBindable`` value, like `LockIsolated`.
  public init<Bindable: ProxyBindable & Sendable>(_ bindable: Bindable)
  where Bindable.Value == Value {
    self.init(
      get: {
        bindable.getValueFunction()
      },
      set: {
        bindable.setValueFunction($0)
      }
    )
  }

  /// Initializes a ``ReadWriteProxy`` from a ``ProxyBindable`` value, like `LockIsolated`.
  public static func bind<Bindable: ProxyBindable & Sendable>(bindable: Bindable) -> Self
  where Bindable.Value == Value {
    .init(bindable)
  }
  /// Initializes a ``ReadWriteProxy`` that returns a constant value.
  public static func constant(_ value: @autoclosure @escaping @Sendable () -> Value)
    -> Self
  {
    .init(get: value, set: { _ in () })
  }
}

/// A property wrapper that characterizes a value that can be read and written synchronously.
///
/// You directly access the value in `live` contexts. In other contexts, you can assign a
/// ``ReadWriteBinding`` to the projected value to control this property during tests and SwiftUI
/// previews:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// let model = withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = .bind(isBatteryMonitoringEnabled)
/// } operation {
///   Model()
/// }
/// isBatteryMonitoryEnabled.withValue { $0 = true }
/// // `@Dependency(\.device.isBatteryMonitoryEnabled) var isBatteryMonitoryEnabled` now returns
/// // `true` in your model…
/// ```
@propertyWrapper
public struct ReadWriteProxy<Value: Sendable>: Sendable {
  @Dependency(\.context) var context

  fileprivate var binding: ReadWriteBinding<Value>

  public init(_ binding: ReadWriteBinding<Value>) {
    self.binding = binding
  }

  @_spi(Internals)
  public var wrappedValue: Value {
    get {
      self.binding.get()
    }
    nonmutating set {
      self.binding.set(newValue)
    }
  }

  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

/// A property wrapper that characterizes a value that can be read synchronously.
///
/// You directly access the value in `live` contexts. In other contexts, you can assign a constant
/// or a function that generates this value to the projected value to control this property during
/// tests and SwiftUI previews:
///
/// ```swift
/// let batteryLevel = LockIsolated(0.4)
/// let model = withDependencies {
///   $0.device.$batteryLevel = { batteryLevel.value }
///   // Or, if this value is contant during your test:
///   $0.device.$batteryLevel = 0.8
/// } operation {
///   Model()
/// }
/// batteryLevel.withValue { $0 = 0.8 }
/// // `@Dependency(\.device.batteryLevel) var batteryLevel` now returns
/// // `0.8` in your model…
/// ```
@propertyWrapper
public struct ReadOnlyProxy<Value: Sendable>: Sendable {
  var _value: @Sendable () -> Value

  public init(_ value: @autoclosure @escaping @Sendable () -> Value) {
    self._value = value
  }
  public init(_ value: @escaping @Sendable () -> Value) {
    self._value = value
  }

  @_spi(Internals)
  public var wrappedValue: Value {
    _value()
  }
  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

/// A property wrapper that characterizes a function that is backed by another value.
///
/// You directly access the value in `live` contexts. In other contexts, you can assign another
/// function to the projected value to control this property during tests and SwiftUI previews:
///
/// ```swift
/// let isClicked = expectation(description: "An input click is played")
/// let model = withDependencies {
///   $0.device.$playInputClick = { isClicked.fulfill() }
///   // Or, if this value is contant during your test:
///   $0.device.$batteryLevel = 0.8
/// } operation {
///   Model()
/// }
/// model.playClick()
/// // This called `self.device.playInputClick()` in `@Dependency(\.device) var device`, so:
/// wait(for: [isClicked], timeout: 1)
/// ```
@propertyWrapper
public struct FunctionProxy<Value: Sendable>: Sendable {
  var _value: @Sendable () -> Value

  public init(_ value: @escaping @Sendable () -> Value) {
    self._value = value
  }

  public init(_ value: Value) {
    self._value = { value }
  }

  @_spi(Internals)
  public var wrappedValue: Value {
    _value()
  }
  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

/// A value that describes a bidirectional binding on `MainActor`.
///
/// You use this type to mock the storage of ``MainActorReadWriteProxy`` properties:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = MainActorReadWriteBinding(isBatteryMonitoringEnabled)
/// } operation { … }
/// ```
/// This allows to inspect and control dependencies exposing writable properties.
/// See ``ReadWriteBinding`` for a version that is not actor-isolated.
public struct MainActorReadWriteBinding<Value>: Sendable {
  let get: @Sendable @MainActor () -> Value
  let set: @Sendable @MainActor (Value) -> Void

  public init(
    get: @escaping @MainActor @Sendable () -> Value,
    set: @escaping @MainActor @Sendable (Value) -> Void
  ) {
    self.get = get
    self.set = set
  }

  @available(*, deprecated, message: "Use the two-argument `get:set:` variant.")
  public init(
    get: @autoclosure @escaping @MainActor @Sendable () -> Value,
    set: @escaping @MainActor @Sendable (Value) -> Void
  ) {
    self.get = get
    self.set = set
  }

  @available(*, deprecated, message: "Use the two-arguments `get:set:` variant.")
  public init(_ getSet: (@MainActor @Sendable () -> Value, @MainActor @Sendable (Value) -> Void)) {
    self.get = getSet.0
    self.set = getSet.1
  }

  public init<Bindable: ProxyBindable & Sendable>(_ bindable: Bindable)
  where Bindable.Value == Value {
    self.init(
      get: {
        bindable.getValueFunction()
      },
      set: {
        bindable.setValueFunction($0)
      }
    )
  }

  public static func constant(_ value: @autoclosure @escaping @Sendable () -> Value)
    -> MainActorReadWriteBinding<Value>
  {
    .init(get: value, set: { _ in })
  }
}

/// A property wrapper that characterizes a value that can be read and written synchronously
/// on the `MainActor`.
///
/// You directly access the value in `live` contexts. In other contexts, you can assign a
/// ``MainActorReadWriteBinding`` to the projected value to control this property during tests and
/// SwiftUI previews:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// let model = withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = .bind(isBatteryMonitoringEnabled)
/// } operation {
///   Model()
/// }
/// isBatteryMonitoryEnabled.withValue { $0 = true }
/// // `@Dependency(\.device.isBatteryMonitoryEnabled) var isBatteryMonitoryEnabled` now returns
/// // `true` in your model…
/// ```
@propertyWrapper
public struct MainActorReadWriteProxy<Value: Sendable>: Sendable {
  @Dependency(\.context) var context

  fileprivate var binding: MainActorReadWriteBinding<Value>
  @available(*, deprecated, message: "")
  public init(
    _ getSet: (
      get: @Sendable @MainActor () -> Value,
      set: @Sendable @MainActor (Value) -> Void
    )
  ) {
    self.binding = .init(get: getSet.get, set: getSet.set)
  }

  public init(_ binding: MainActorReadWriteBinding<Value>) {
    self.binding = binding
  }

  @MainActor
  @_spi(Internals)
  public var wrappedValue: Value {
    get {
      self.binding.get()
    }
    nonmutating set {
      self.binding.set(newValue)
    }
  }

  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

/// A property wrapper that characterizes a value that can be read synchronously on the
/// `MainActor`
///
/// You directly access the value in `live` contexts. In other contexts, you can assign a constant
/// or a function that generates this value to the projected value to control this property during
/// tests and SwiftUI previews:
///
/// ```swift
/// let batteryLevel = LockIsolated(0.4)
/// let model = withDependencies {
///   $0.device.$batteryLevel = { batteryLevel.value }
///   // Or, if this value is contant during your test:
///   $0.device.$batteryLevel = 0.8
/// } operation {
///   Model()
/// }
/// batteryLevel.withValue { $0 = 0.8 }
/// // `@Dependency(\.device.batteryLevel) var batteryLevel` now returns
/// // `0.8` in your model…
/// ```
@propertyWrapper
public struct MainActorReadOnlyProxy<Value: Sendable>: Sendable {
  var _value: @Sendable @MainActor () -> Value

  public init(_ value: @autoclosure @escaping @MainActor @Sendable () -> Value) {
    self._value = value
  }
  public init(_ value: @escaping @MainActor @Sendable () -> Value) {
    self._value = value
  }
  @MainActor
  @_spi(Internals)
  public var wrappedValue: Value {
    _value()
  }
  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

/// A protocol that describes values that can support other values in "`Proxy`" property wrappers
/// like ``ReadWriteProxy`` and ``MainActorReadOnlyProxy``.
///
/// Type conforming to this protocol can be simply bound to dependencies values. You then act on
/// this type and the values will propagate to the dependencies you bind them to. Reciprocally,
/// their state should be able to reflect the current state of the bound dependencies, if they were
/// modified by your model itself for example.
///
/// `LockIsolated` is conforming to this protocol, so you can use `LockIsolated` values
/// to control writable dependencies properties during tests and SwiftUI previews.
//@dynamicMemberLookup
public protocol ProxyBindable {
  associatedtype Value
  @available(*, deprecated, message: "Implement `getValueFunction()` instead")
  var getValue: @Sendable () -> Value { get }
  @available(*, deprecated, message: "Implement `setValueFunction()` instead")
  var setValue: @Sendable (Value) -> Void { get }
  
  /// This will be renamed `getValue` in the future when the deprecated `getValue` closure will be
  /// removed.
  func getValueFunction() -> Value
  /// This will be renamed `setValue` in the future when the deprecated `setValue` closure will be
  /// removed.
  func setValueFunction(_ value: Value)
}

extension ProxyBindable where Self: Sendable {
  @_spi(Internals) public var getValue: @Sendable () -> Value {
    { self.getValueFunction() }
  }
  @_spi(Internals) public var setValue: @Sendable (Value) -> Void {
    { self.setValueFunction($0) }
  }
}

// // Removed for now until a proper way to handle the non-sendable capture is found
//extension ProxyBindable {
//  public subscript(dynamicMember keyPath: ReferenceWritableKeyPath<Self, Value>)
//  -> AnyProxyBindable<Value> where Value: Sendable
//  {
//    return AnyProxyBindable<Value>(
//      getValue: { self[keyPath: keyPath] },
//      setValue: { self[keyPath: keyPath] = $0 }
//    )
//  }
//}

/// An erased ``ProxyBindable`` property.
///
/// You usually obtain this type by drilling into `ProxyBindable` instance writable properties.
///
/// For example, `LockIsolated(["a", "b", "c"]).count` returns an ``AnyProxyBindable<Int>``
/// that you can bind to a writable dependency.
public struct AnyProxyBindable<Value: Sendable>: ProxyBindable {
  public var getValue: @Sendable () -> Value
  public var setValue: @Sendable (Value) -> Void
  @_spi(Internals) public func getValueFunction() -> Value {
    self.getValue()
  }
  @_spi(Internals) public func setValueFunction(_ value: Value) {
    self.setValue(value)
  }
}

extension LockIsolated: ProxyBindable {
  @_spi(Internals) public func getValueFunction() -> Value where Value: Sendable {
    self.value
  }
  
  @_spi(Internals) public func setValueFunction(_ value: Value) where Value: Sendable {
    self.withValue {
      $0 = value
    }
  }
}

// TODO: Reword and reinsert.
//private func warnIfLive<Value, Container>(
//  type: Value.Type, container: Container.Type, context: DependencyContext, readonly: Bool
//) {
//  if context == .live {
//    runtimeWarn(
//      """
//      Trying to set a \(Value.self) using the projected value of a `\(Container.self)` in a live \
//      context.
//
//      This projected value should only be used to override values during testing or in SwiftUI \
//      Previews.\( readonly ? " In a live context, this value is assumed to be read-only." : "")
//      """
//    )
//  }
//}

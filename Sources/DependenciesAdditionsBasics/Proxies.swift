import Dependencies

@dynamicMemberLookup
public protocol ConfigurableProxy {
  associatedtype Implementation
  var _implementation: Implementation { get set }

  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadWriteProxy<Value>>)
    -> ReadWriteBinding<Value>
  { get set }

  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>)
    -> @Sendable () -> Value
  { get set }

  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, ReadOnlyProxy<Value>>)
    -> Value
  { get set }

  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Implementation, FunctionProxy<Value>>)
    -> Value
  { get set }

  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadWriteProxy<Value>>
  )
    -> MainActorReadWriteBinding<Value>
  { get set }

  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  )
    -> @MainActor @Sendable () -> Value
  { get set }

  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorReadOnlyProxy<Value>>
  )
    -> Value
  { @MainActor get set }

  subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorFunctionProxy<Value>>
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

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Implementation, MainActorFunctionProxy<Value>>
  ) -> Value {
    @MainActor get { self._implementation[keyPath: keyPath]._value() }
    set { self._implementation[keyPath: keyPath]._value = { newValue } }
  }
}

/// A value that describe a bidirectional binding.
///
/// You use this type to mock the storage of ``ReadWriteProxy`` properties:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = ReadWriteBinding(isBatteryMonitoringEnabled)
/// } operation {…}
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

  // This one will be deprecated soon
  @_spi(Internals) public init(_ getSet: (@Sendable () -> Value, @Sendable (Value) -> Void)) {
    self.get = getSet.0
    self.set = getSet.1
  }
  /// Initializes a ``ReadWriteProxy`` from a ``ProxyBindable`` value, like `LockIsolated`.
  public init<Bindable: ProxyBindable & Sendable>(_ bindable: Bindable)
  where Bindable.Value == Value {
    self.init(
      get: {
        bindable.getValue()
      },
      set: {
        bindable.setValue($0)
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

extension ReadWriteBinding {
  public static func unimplemented(
    description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    let value = LockIsolated<() -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
  public static func unimplemented(
    description: String,
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    let value = LockIsolated<() -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
}

/// A property wrapper that characterizes a value that can be read and written synchronously.
///
/// You directly access the value in `live` context. In other context, you can assign a
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

extension ReadWriteProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadWriteProxy(
      .unimplemented(
        description: description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "", placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadWriteProxy(
      .unimplemented(
        description: description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
  }
}

/// A property wrapper that characterizes a value that can be read synchronously.
///
/// You directly access the value in `live` context. In other context, you can assign a constant or
/// a function that generates this value to the projected value to control this property during
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

extension ReadOnlyProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadOnlyProxy(
      XCTestDynamicOverlay.unimplemented(description, file: file, fileID: fileID, line: line))
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    ReadOnlyProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

/// A property wrapper that characterizes a function that is backed by another type.
///
/// You directly access the value in `live` context. In other context, you can assign another
/// a function to the projected value to control this property during tests and SwiftUI previews:
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

  @_spi(Internals)
  public var wrappedValue: Value {
    _value()
  }
  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

extension FunctionProxy {
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    FunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

func _unimplemented<V>(
  description: String,
  file: StaticString = #file,
  fileID: StaticString = #fileID,
  line: UInt = #line
) -> V {
  { unimplemented(description, file: file, fileID: fileID, line: line) }()
}

/// A value that describe a bidirectional binding on `MainActor`.
///
/// You use this type to mock the storage of ``MainActorReadWriteProxy`` properties:
///
/// ```swift
/// let isBatteryMonitoringEnabled = LockIsolated(false)
/// withDependencies {
///   $0.device.$isBatteryMonitoringEnabled = MainActorReadWriteBinding(isBatteryMonitoringEnabled)
/// } operation {…}
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
  public init(
    get: @autoclosure @escaping @MainActor @Sendable () -> Value,
    set: @escaping @MainActor @Sendable (Value) -> Void
  ) {
    self.get = get
    self.set = set
  }

  public init(_ getSet: (@MainActor @Sendable () -> Value, @MainActor @Sendable (Value) -> Void)) {
    self.get = getSet.0
    self.set = getSet.1
  }

  public init<Bindable: ProxyBindable & Sendable>(_ bindable: Bindable)
  where Bindable.Value == Value {
    self.init(
      get: {
        bindable.getValue()
      },
      set: {
        bindable.setValue($0)
      }
    )
  }

  public static func constant(_ value: @autoclosure @escaping @Sendable () -> Value)
    -> MainActorReadWriteBinding<Value>
  {
    .init(get: value()) { _ in () }
  }
}

extension MainActorReadWriteBinding {
  public static func unimplemented(
    description: String,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    let value = LockIsolated<() -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
  public static func unimplemented(
    description: String,
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    let value = LockIsolated<() -> Value>(
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
    return .init {
      value.value()
    } set: { newValue in
      value.withValue {
        $0 = { newValue }
      }
    }
  }
}

/// A property wrapper that characterizes a value that can be read and written synchronously
/// on the `MainActor`.
///
/// You directly access the value in `live` context. In other context, you can assign a
/// ``MainActorReadWriteBinding`` to the projected value to control this property during tests and SwiftUI
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

extension MainActorReadWriteProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadWriteProxy(
      .unimplemented(
        description: description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadWriteProxy(
      .unimplemented(
        description: description,
        placeholder: placeholder(),
        fileID: fileID,
        line: line
      )
    )
  }
}

/// A property wrapper that characterizes a value that can be read synchronously on the
/// `MainActor`
///
/// You directly access the value in `live` context. In other context, you can assign a constant or
/// a function that generates this value to the projected value to control this property during
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

extension MainActorReadOnlyProxy {
  public static func unimplemented(
    _ description: String = "",
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadOnlyProxy(
      XCTestDynamicOverlay.unimplemented(
        description,
        file: file,
        fileID: fileID,
        line: line
      )
    )
  }
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorReadOnlyProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

/// A property wrapper that characterizes a `MainActor` function that is backed by another type.
///
/// You directly access the value in `live` context. In other context, you can assign another
/// a function to the projected value to control this property during tests and SwiftUI previews:
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
public struct MainActorFunctionProxy<Value: Sendable>: Sendable {
  var _value: @Sendable @MainActor () -> Value

  public init(_ value: @escaping @Sendable @MainActor () -> Value) {
    self._value = value
  }

  @_spi(Internals)
  @MainActor
  public var wrappedValue: Value {
    _value()
  }
  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }
}

extension MainActorFunctionProxy {
  public static func unimplemented(
    _ description: String = "",
    placeholder: @autoclosure @escaping @Sendable () -> Value,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    MainActorFunctionProxy({
      XCTestDynamicOverlay.unimplemented(
        description,
        placeholder: placeholder,
        fileID: fileID,
        line: line
      )()
    })
  }
}

/// A protocol that describe values that can support other values in "`Proxy`" property
/// wrappers like ``ReadWriteProxy`` and ``MainActorReadOnlyProxy``.
///
/// Type conforming to this protocol can be simply bound to dependencies values. You then
/// act on this type and the the values will propagate to the dependencies you bound them
/// to. Reciprocally, their state should be able to reflect the current state of the bound
/// dependencies if it was modified by your model itself for example.
///
/// `LockIsolated` is conforming to this protocol, so you can use `LockIsolated` values
/// to control writable dependencies properties during tests and SwiftUI previews.
//@dynamicMemberLookup
public protocol ProxyBindable {
  associatedtype Value: Sendable
  var getValue: @Sendable () -> Value { get }
  var setValue: @Sendable (Value) -> Void { get }
}

// Removed for now until a proper way to handle the non-sendable capture is found
//extension ProxyBindable {
//  public subscript(dynamicMember keyPath: ReferenceWritableKeyPath<Self, Value>)
//    -> AnyProxyBindable<Value>
//  {
//    return AnyProxyBindable<Value>(
//      getValue: { self[keyPath: keyPath] },
//      setValue: { self[keyPath: keyPath] = $0 }
//    )
//  }
//}

/// An erased ``ProxyBindable`` property.
///
/// You usually obtain this type by drilling into `ProxyBindable` instance writable
/// properties.
///
/// For example, `LockIsolated(["a", "b", "c"]).count` returns an ``AnyProxyBindable<Int>``
/// that you can bind to a writable dependency.
public struct AnyProxyBindable<Value: Sendable>: ProxyBindable {
  public var getValue: @Sendable () -> Value
  public var setValue: @Sendable (Value) -> Void
}

extension LockIsolated: ProxyBindable {
  public var getValue: @Sendable () -> Value {
    { self.value }
  }

  public var setValue: @Sendable (Value) -> Void {
    { value in
      self.withValue { inner in
        inner = value
      }
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

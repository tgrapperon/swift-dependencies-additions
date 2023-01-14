@_spi(Internals)
@MainActor
public final class MainActorIsolated<Value>: Sendable {
  public lazy var value: Value = initialValue()
  private let initialValue: @MainActor () -> Value
  
  nonisolated public init(initialValue: @MainActor @escaping () -> Value) {
    self.initialValue = initialValue
  }
  public subscript<Subject: Sendable>(
    dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>
  )
    -> Subject
  {
    get { self.value[keyPath: keyPath] }
    set { self.value[keyPath: keyPath] = newValue }
  }
}

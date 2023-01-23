import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import XCTest

final class ProxiesTests: XCTestCase {
  func testReadWriteProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @ReadWriteProxy var value: String
      }
      var _implementation: Implementation
      var value: String {
        get { _implementation.value }
        nonmutating set { _implementation.value = newValue }
      }
    }
    let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    unimplemented.value = "Hello!"
    XCTAssertEqual("Hello!", unimplemented.value)
  }

  func testReadOnlyProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @ReadOnlyProxy var value: String
      }
      var _implementation: Implementation
      var value: String {
        _implementation.value
      }
    }
    var unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    unimplemented.$value = "Hello!"
    XCTAssertEqual("Hello!", unimplemented.value)
  }

  func testFunctionProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @FunctionProxy var value: (Int) -> String
      }
      var _implementation: Implementation
      func value(index: Int) -> String {
        _implementation.value(index)
      }
    }
    var unimplemented = Foo(_implementation: .init(value: .unimplemented(placeholder: { _ in "" })))
    unimplemented.$value = { "Hello! \($0)" }
    XCTAssertEqual("Hello! 3", unimplemented.value(index: 3))
  }
  
  @MainActor
  func testMainActorReadWriteProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @MainActorReadWriteProxy var value: String
      }
      var _implementation: Implementation
      @MainActor
      var value: String {
        get { _implementation.value }
        nonmutating set { _implementation.value = newValue }
      }
    }
    let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    unimplemented.value = "Hello!"
    XCTAssertEqual("Hello!", unimplemented.value)
  }
  
@MainActor
  func testMainActorReadOnlyProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @MainActorReadOnlyProxy var value: String
      }
      var _implementation: Implementation
      @MainActor
      var value: String {
        _implementation.value
      }
    }
    var unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    unimplemented.$value = "Hello!"
    XCTAssertEqual("Hello!", unimplemented.value)
  }

  #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    func testUnimplementedReadWriteProxy() {
      struct Foo: ConfigurableProxy {
        struct Implementation {
          @ReadWriteProxy var value: String
        }
        var _implementation: Implementation
        var value: String {
          get { _implementation.value }
          nonmutating set { _implementation.value = newValue }
        }
      }
      let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
      XCTExpectFailure {
        let _ = unimplemented.value
      }
      unimplemented.value = "Hello!"  // This shouldn't trip .unimplemented
    }

    func testUnimplementedReadOnlyProxy() {
      struct Foo: ConfigurableProxy {
        struct Implementation {
          @ReadOnlyProxy var value: String
        }
        var _implementation: Implementation
        var value: String {
          _implementation.value
        }
      }
      let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
      XCTExpectFailure {
        let _ = unimplemented.value
      }
    }

    func testUnimplementedFunctionProxy() {
      struct Foo: ConfigurableProxy {
        struct Implementation {
          @FunctionProxy var value: (Int) -> String
        }
        var _implementation: Implementation
        func value(index: Int) -> String {
          _implementation.value(index)
        }
      }
      let unimplemented = Foo(
        _implementation: .init(value: .init({ XCTestDynamicOverlay.unimplemented() })))
      XCTExpectFailure {
        let _ = unimplemented.value(index: 4)
      }
    }
  
  @MainActor
  func testUnimplementedMainActorReadWriteProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @MainActorReadWriteProxy var value: String
      }
      var _implementation: Implementation
      @MainActor
      var value: String {
        get { _implementation.value }
        nonmutating set { _implementation.value = newValue }
      }
    }
    let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    XCTExpectFailure {
      let _ = unimplemented.value
    }
    unimplemented.value = "Hello!"  // This shouldn't trip .unimplemented
  }

  @MainActor
  func testUnimplementedMainActorReadOnlyProxy() {
    struct Foo: ConfigurableProxy {
      struct Implementation {
        @MainActorReadOnlyProxy var value: String
      }
      var _implementation: Implementation
      @MainActor
      var value: String {
        _implementation.value
      }
    }
    let unimplemented = Foo(_implementation: .init(value: .unimplemented()))
    XCTExpectFailure {
      let _ = unimplemented.value
    }
  }
  #endif
}

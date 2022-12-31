import Dependencies
import PathDependency
import XCTest

final class PathDependencyTests: XCTestCase {
  @Dependency(\.path) var path

  func testPath() {
    final class Model {
      @Dependency(\.path) var path
      var model1: Model?
      var model2: Model?
      init(
        model1: (() -> Model)? = nil,
        model2: (() -> Model)? = nil
      ) {
        self.model1 = model1?()
        self.model2 = model2?()
      }
    }

    let model = Model {
      withDependencyValues {
        $0.path.push("a1")
      } operation: {
        .init {
          withDependencyValues {
            $0.path.push("b1")
          } operation: {
            .init {
              withDependencyValues {
                $0.path.push("c1")
              } operation: {
                .init()
              }
            } model2: {
              .init()
            }
          }
        } model2: {
          withDependencyValues {
            $0.path.push("b2")
          } operation: {
            .init {
              withDependencyValues {
                $0.path.push("c1")
              } operation: {
                .init()
              }
            } model2: {
              withDependencyValues {
                $0.path.push("c2")
              } operation: {
                .init()
              }
            }
          }
        }
      }
    } model2: {
      withDependencyValues {
        $0.path.push("a2")
      } operation: {
        .init()
      }
    }

    XCTAssertEqual(model.model1?.model1?.model1?.path.components, ["a1", "b1", "c1"])
    XCTAssertEqual(model.model1?.model1?.model2?.path.components, ["a1", "b1"])
    XCTAssertEqual(model.model1?.model2?.model1?.path.components, ["a1", "b2", "c1"])
    XCTAssertEqual(model.model1?.model2?.model2?.path.components, ["a1", "b2", "c2"])
    XCTAssertEqual(model.model2?.path.components, ["a2"])
  }
}

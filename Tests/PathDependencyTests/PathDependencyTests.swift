import Dependencies
import PathDependency
import XCTest

@MainActor
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

    let model = withDependencies {
      $0.path = .empty
    } operation: {
      Model {
        withDependencies {
          $0.path.append("a1")
        } operation: {
          .init {
            withDependencies {
              $0.path.append("b1")
            } operation: {
              .init {
                withDependencies {
                  $0.path.append("c1")
                } operation: {
                  .init()
                }
              } model2: {
                .init()
              }
            }
          } model2: {
            withDependencies {
              $0.path.append("b2")
            } operation: {
              .init {
                withDependencies {
                  $0.path.append("c1")
                } operation: {
                  .init()
                }
              } model2: {
                withDependencies {
                  $0.path.append("c2")
                } operation: {
                  .init()
                }
              }
            }
          }
        }
      } model2: {
        withDependencies {
          $0.path.append("a2")
        } operation: {
          .init()
        }
      }
    }

    XCTAssertEqual(model.model1?.model1?.model1?.path.components, ["a1", "b1", "c1"])
    XCTAssertEqual(model.model1?.model1?.model2?.path.components, ["a1", "b1"])
    XCTAssertEqual(model.model1?.model2?.model1?.path.components, ["a1", "b2", "c1"])
    XCTAssertEqual(model.model1?.model2?.model2?.path.components, ["a1", "b2", "c2"])
    XCTAssertEqual(model.model2?.path.components, ["a2"])
  }
}

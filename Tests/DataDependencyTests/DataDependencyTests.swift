import DataDependency
import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import XCTest

@MainActor
final class DataDependencyTests: XCTestCase {

  func testEphemeralRoundTripping() throws {
    @Dependency(\.dataProvider) var dataProvider
    let _ = __dummySeparator__
    try withDependencies {
      $0.dataProvider = .ephemeral()
    } operation: {
      let input = "1234".data(using: .utf8)!
      let url = FileManager.default.temporaryDirectory.appendingPathExtension("Test.txt")
      try input.write(to: url, writer: dataProvider)
      let retrieved = try Data(contentsOf: url, reader: dataProvider)
      XCTAssertEqual(input, retrieved)
    }

  }
}

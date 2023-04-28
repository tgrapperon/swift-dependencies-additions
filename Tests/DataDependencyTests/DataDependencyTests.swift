import DataDependency
import Dependencies
import DependenciesAdditionsBasics
import XCTest

final class DataDependencyTests: XCTestCase {

  func testEphemeralRoundTripping() throws {
    @Dependency(\.dataProvider) var dataProvider: any DataProviderProtocol

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

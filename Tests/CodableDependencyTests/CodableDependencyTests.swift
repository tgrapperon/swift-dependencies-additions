import CodableDependency
import Dependencies
import XCTest

@MainActor
final class CodableDependencyTests: XCTestCase {
  @Dependency(\.encode) var encode
  @Dependency(\.decode) var decode

  func testCompressionDecompression() async throws {
    let dictionary = ["xyz": "ABC"]

    try withDependencies {
      $0.encode = .json
      $0.decode = .json
    } operation: {
      let coded = try encode(dictionary)
      let decoded = try decode([String: String].self, from: coded)
      XCTAssertEqual(dictionary, decoded)
    }

  }
}

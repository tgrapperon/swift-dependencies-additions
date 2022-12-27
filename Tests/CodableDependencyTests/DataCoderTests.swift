import CodableDependency
import Dependencies
import XCTest

final class DataCoderTests: XCTestCase {
  @Dependency(\.encode) var encode
  @Dependency(\.decode) var decode

  func testCompressionDecompression() async throws {
    let dictionary = ["xyz": "ABC"]

    let coded = try encode(dictionary)

    let decoded = try decode([String: String].self, from: coded)
    XCTAssertEqual(dictionary, decoded)
  }
}

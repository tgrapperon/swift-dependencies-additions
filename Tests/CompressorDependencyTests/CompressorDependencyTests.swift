import CompressorDependency
import Dependencies
import XCTest

final class CompressorDependencyTests: XCTestCase {
  @Dependency(\.compress) var compress
  @Dependency(\.decompress) var decompress

  func testCompressionDecompression() async throws {
    let data = String(repeating: "A", count: 1000).data(using: .utf8)!
    
    let compressed = try await compress(data)
    XCTAssertTrue(compressed.count < data.count)
    let decompressed = try await decompress(compressed)
    XCTAssertEqual(data, decompressed)
  }
}

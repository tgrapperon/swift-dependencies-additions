// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

///
/// - `DependenciesAdditionsBasics`: Only utilities and direct extensions to `swift-dependencies`.

let package = Package(
  name: "Basics",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "DependenciesAdditionsBasics", targets: ["DependenciesAdditionsBasics"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
  ],
  targets: [

    .target(
      name: "DependenciesAdditionsBasics",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .testTarget(
      name: "DependenciesAdditionsBasicsTests",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "DependenciesAdditionsBasics",
      ]
    ),
  ]
)

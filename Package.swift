// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DependenciesAdditions",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", branch: "main")
  ]
)

define("DependenciesAdditions")
define("AppStorage")
define("BundleInfo")
//define("CoreDataDependency")
define("DataCoder")
define("LoggerDependency")
define("CompressorDependency")
//define("CryptoDependency")
//define("KeyChainDependency")
//define("NotificationDependency")
define("SwiftUIDependency")

func define(_ target: String) {
  package.targets.append(
    .target(name: target, dependencies: [.product(name: "Dependencies", package: "swift-dependencies")])
  )
  package.targets.append(
    .testTarget(name: "\(target)Tests", dependencies: [.target(name: target)])
  )
  package.products.append(.library(name: target, targets: [target]))
}

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(
    .unsafeFlags([
      "-Xfrontend", "-warn-concurrency",
      "-Xfrontend", "-enable-actor-data-race-checks",
//      "-enable-library-evolution",
    ])
  )
}

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

/// Temporary helpers
define("DependenciesAdditions")
define(
  "AppStorageDependency",
  dependencies: "UserDefaultsDependency",
  testingDependencies: "DependenciesAdditions"
)

define("BundleInfoDependency")
define("PersistentContainerDependency")
define("CoreDataDependency", dependencies: "DependenciesAdditions", "PersistentContainerDependency")
define("CodableDependency")
define("LoggerDependency", dependencies: "BundleInfoDependency")
define("CompressionDependency")
//define("CryptoDependency")
//define("KeyChainDependency")
define("ProcessInfoDependency")
define("NotificationDependency", dependencies: "DependenciesAdditions")
define("UserDefaultsDependency")
define("SwiftUIDependency", testingDependencies: "DependenciesAdditions")

func define(_ target: String, dependencies: String..., testingDependencies: String...) {
  var targetDependencies: [Target.Dependency] = [
    .product(name: "Dependencies", package: "swift-dependencies")
  ]
  for dependency in dependencies {
    targetDependencies.append(.target(name: dependency))
  }
  package.targets.append(
    .target(
      name: target, dependencies: targetDependencies)
  )
  var targetTestingDependencies: [Target.Dependency] = [
    .target(name: target)
  ]
  for dependency in testingDependencies {
    targetTestingDependencies.append(.target(name: dependency))
  }
  package.targets.append(
    .testTarget(name: "\(target)Tests", dependencies: targetTestingDependencies)
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

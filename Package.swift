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
  products: [
    .library(
      name: "DependenciesAdditions",
      targets: [
        "BundleInfoDependency",
        "CodableDependency",
        "CompressionDependency",
        "DependenciesAdditions",
        "DeviceDependency",
        "LoggerDependency",
        "PathDependency",
        "PersistentContainerDependency",
        "ProcessInfoDependency",
        "UserDefaultsDependency",
        "_AppStorageDependency",
        "_CoreDataDependency",
        "_NotificationDependency",
        "_SwiftUIDependency",
      ]
    ),
    .library(name: "BundleInfoDependency", targets: ["BundleInfoDependency"]),
    .library(name: "CodableDependency", targets: ["CodableDependency"]),
    .library(name: "CompressionDependency", targets: ["CompressionDependency"]),
    .library(name: "DeviceDependency", targets: ["DeviceDependency"]),
    .library(name: "LoggerDependency", targets: ["LoggerDependency"]),
    .library(name: "PathDependency", targets: ["PathDependency"]),
    .library(name: "PersistentContainerDependency", targets: ["PersistentContainerDependency"]),
    .library(name: "ProcessInfoDependency", targets: ["ProcessInfoDependency"]),
    .library(name: "UserDefaultsDependency", targets: ["UserDefaultsDependency"]),
    .library(name: "_AppStorageDependency", targets: ["_AppStorageDependency"]),
    .library(name: "_CoreDataDependency", targets: ["_CoreDataDependency"]),
    .library(name: "_NotificationDependency", targets: ["_NotificationDependency"]),
    .library(name: "_SwiftUIDependency", targets: ["_SwiftUIDependency"]),

  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", branch: "main"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "_AppStorageDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
        "UserDefaultsDependency",
      ]
    ),
    .testTarget(
      name: "_AppStorageDependencyTests",
      dependencies: [
        "_AppStorageDependency",
        "DependenciesAdditionsTestSupport",
      ]
    ),

    .target(
      name: "BundleInfoDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
      ]
    ),
    .testTarget(
      name: "BundleInfoDependencyTests",
      dependencies: [
        "BundleInfoDependency"
      ]
    ),

    .target(
      name: "CodableDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .testTarget(
      name: "CodableDependencyTests",
      dependencies: [
        "CodableDependency"
      ]
    ),

    .target(
      name: "CompressionDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .testTarget(
      name: "CompressionDependencyTests",
      dependencies: [
        "CompressionDependency"
      ]
    ),

    .target(
      name: "_CoreDataDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
        "PersistentContainerDependency",
      ]
    ),
    .testTarget(
      name: "_CoreDataDependencyTests",
      dependencies: [
        "_CoreDataDependency"
      ]
    ),

    .target(
      name: "DependenciesAdditions",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .testTarget(
      name: "DependenciesAdditionsTests",
      dependencies: [
        "DependenciesAdditions"
      ]
    ),

    .target(
      name: "DependenciesAdditionsTestSupport",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .target(
      name: "DeviceDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
      ]
    ),

    .testTarget(
      name: "DeviceDependencyTests",
      dependencies: [
        "DeviceDependency"
      ]
    ),

    .target(
      name: "LoggerDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "BundleInfoDependency",
      ]
    ),

    .testTarget(
      name: "LoggerDependencyTests",
      dependencies: [
        "LoggerDependency"
      ]
    ),

    .target(
      name: "_NotificationDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
        "PathDependency",
      ]
    ),

    .testTarget(
      name: "_NotificationDependencyTests",
      dependencies: [
        "_NotificationDependency",
        "DependenciesAdditionsTestSupport",
      ]
    ),

    .target(
      name: "PathDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .testTarget(
      name: "PathDependencyTests",
      dependencies: [
        "PathDependency"
      ]
    ),

    .target(
      name: "PersistentContainerDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .testTarget(
      name: "PersistentContainerDependencyTests",
      dependencies: [
        "PersistentContainerDependency"
      ]
    ),

    .target(
      name: "ProcessInfoDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesAdditions",
      ]
    ),

    .testTarget(
      name: "ProcessInfoDependencyTests",
      dependencies: [
        "ProcessInfoDependency"
      ]
    ),

    .target(
      name: "_SwiftUIDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .testTarget(
      name: "_SwiftUIDependencyTests",
      dependencies: [
        "_SwiftUIDependency",
        "DependenciesAdditionsTestSupport",
      ]
    ),

    .target(
      name: "UserDefaultsDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),

    .testTarget(
      name: "UserDefaultsDependencyTests",
      dependencies: [
        "UserDefaultsDependency"
      ]
    ),
  ]
)

/// Temporary helpers

// define(
//  "_CoreDataDependency", dependencies: "DependenciesBaseAdditions", "PersistentContainerDependency"
// )
// define("_NotificationDependency", dependencies: "DependenciesBaseAdditions", "PathDependency")
// define("BundleInfoDependency", dependencies: "DependenciesBaseAdditions")

// define("DeviceDependency", dependencies: "DependenciesBaseAdditions")
// define("LoggerDependency", dependencies: "BundleInfoDependency")

// define("CompressionDependency")
// define("PathDependency")
// define("PersistentContainerDependency")
// define("ProcessInfoDependency")
// define("UserDefaultsDependency")

// define("CryptoDependency")
// define("KeyChainDependency")
// define("Version")?

func define(_ target: String, dependencies: String..., testingDependencies: String...) {
  var targetDependencies: [Target.Dependency] = [
    .product(name: "Dependencies", package: "swift-dependencies")
  ]
  for dependency in dependencies {
    targetDependencies.append(.target(name: dependency))
  }
  package.targets.append(
    .target(
      name: target, dependencies: targetDependencies
    )
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

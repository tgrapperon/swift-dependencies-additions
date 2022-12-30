// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DependenciesAdditions",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "DependenciesAdditions",
      targets: [
        "DependenciesAdditions"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", branch: "main"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", branch: "autoclosures"),
  ],
  targets: [
    .target(
      name: "_AppStorageDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesBaseAdditions",
        "UserDefaultsDependency"
      ]
    ),
    .testTarget(
      name: "_AppStorageDependencyTests",
      dependencies: [
        "_AppStorageDependency",
        "DependenciesBaseAdditions"
      ]
    ),

    .target(
      name: "BundleInfoDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesBaseAdditions",
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
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
        "DependenciesBaseAdditions",
        "PersistentContainerDependency"
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        "_AppStorageDependency",
        "_CoreDataDependency",
        "_NotificationDependency",
        "_SwiftUIDependency",
        "BundleInfoDependency",
        "CodableDependency",
        "CompressionDependency",
        "DependenciesBaseAdditions",
        "DeviceDependency",
        "LoggerDependency",
        "PathDependency",
        "PersistentContainerDependency",
        "ProcessInfoDependency",
        "UserDefaultsDependency"
      ]
    ),

    .testTarget(
      name: "DependenciesAdditionsTests",
      dependencies: [
        "DependenciesAdditions"
      ]
    ),
    .target(
      name: "DependenciesBaseAdditions",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    
    .testTarget(
      name: "DependenciesBaseAdditionsTests",
      dependencies: [
        "DependenciesBaseAdditions"
      ]
    ),

    .target(
      name: "DeviceDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "DependenciesBaseAdditions"
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
        "DependenciesBaseAdditions"
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
        "DependenciesBaseAdditions",
        "PathDependency"
      ]
    ),
    
    .testTarget(
      name: "_NotificationDependencyTests",
      dependencies: [
        "_NotificationDependency"
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
        .product(name: "Dependencies", package: "swift-dependencies")
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
        "DependenciesBaseAdditions",
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
    )
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
      "-Xfrontend", "-enable-actor-data-race-checks"
      //      "-enable-library-evolution",
    ])
  )
}

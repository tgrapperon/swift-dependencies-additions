// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

///
/// - `DependenciesAdditions`: All non-experimental dependencies;
///
/// - `AccessibilityDependency`:       `\.accessibility`
/// - `ApplicationDependency`:         `\.application`
/// - `AssertionDependency`:           `\.assert` and `\.assertionFailure`
/// - `BundleDependency`:              `\.bundleInfo`
/// - `CodableDependency`:             `\.encode` and `\.decode`
/// - `CompressionDependency`:         `\.compress` and `\.decompress`
/// - `DataDependency`:                `\.dataReader` and `\.dataWriter`
/// - `DeviceDependency`:              `\.device` and `\.deviceCheckDevice`
/// - `LoggerDependency`:              `\.logger`
/// - `NotificationCenterDependency`:  `\.notificationCenter`
/// - `PathDependency`:                `\.path`
/// - `PersistentContainerDependency`: `\.persitentContainer`
/// - `ProcessInfoDependency`:         `\.processInfo`
/// - `UserDefaultsDependency`:        `\.userDefaults`
/// - `UserNotificationsDependency`:   `\.userNotificationCenter`
///
/// - `_AppStorageDependency`:         `@Dependency.AppStorage` property wrapper
/// - `_NotificationDependency`:       `@Dependency.Notification` property wrapper
/// - `_CoreDataDependency`:            wip
/// - `_SwiftUIDependency`:            `@Dependency.Environment` property wrapper

let package = Package(
  name: "swift-dependencies-additions",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "DependenciesAdditions", targets: ["DependenciesAdditions"]),
    .library(name: "_AppStorageDependency", targets: ["_AppStorageDependency"]),
    .library(name: "_CoreDataDependency", targets: ["_CoreDataDependency"]),
    .library(name: "_NotificationDependency", targets: ["_NotificationDependency"]),
    .library(name: "_SwiftUIDependency", targets: ["_SwiftUIDependency"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
    .package(path: "Basics"),
  ],
  targets: [

    .target(
      name: "AccessibilityDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "AccessibilityDependencyTests",
      dependencies: [
        "AccessibilityDependency"
      ]
    ),

    .target(
      name: "ApplicationDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "ApplicationDependencyTests",
      dependencies: [
        "ApplicationDependency"
      ]
    ),

    .target(
      name: "_AppStorageDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "UserDefaultsDependency",
      ]
    ),
    .testTarget(
      name: "_AppStorageDependencyTests",
      dependencies: [
        "_AppStorageDependency"
      ]
    ),

    .target(
      name: "AssertionDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "AssertionDependencyTests",
      dependencies: [
        "AssertionDependency"
      ]
    ),

    .target(
      name: "BundleDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "BundleDependencyTests",
      dependencies: [
        "BundleDependency"
      ]
    ),

    .target(
      name: "CodableDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        "AccessibilityDependency",
        "ApplicationDependency",
        "AssertionDependency",
        "BundleDependency",
        "CodableDependency",
        "CompressionDependency",
        "DataDependency",
        "DeviceDependency",
        "LoggerDependency",
        "NotificationCenterDependency",
        "PathDependency",
        "PersistentContainerDependency",
        "ProcessInfoDependency",
        "UserDefaultsDependency",
        "UserNotificationsDependency",
      ]
    ),

    .target(
      name: "DataDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .testTarget(
      name: "DataDependencyTests",
      dependencies: [
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        "DataDependency",
      ]
    ),

    .target(
      name: "DeviceDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "BundleDependency",
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
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        "AccessibilityDependency",
        "DeviceDependency",
        "NotificationCenterDependency",
      ]
    ),

    .testTarget(
      name: "_NotificationDependencyTests",
      dependencies: [
        "_NotificationDependency"
      ]
    ),

    .target(
      name: "NotificationCenterDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .testTarget(
      name: "NotificationCenterDependencyTests",
      dependencies: [
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        "NotificationCenterDependency",
      ]
    ),

    .target(
      name: "PathDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
      ],
      resources: [
        .process("Model.xcdatamodeld")
      ]
    ),

    .target(
      name: "ProcessInfoDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
      ]
    ),

    .testTarget(
      name: "_SwiftUIDependencyTests",
      dependencies: [
        "_SwiftUIDependency"
      ]
    ),

    .target(
      name: "UserDefaultsDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
      ]
    ),

    .testTarget(
      name: "UserDefaultsDependencyTests",
      dependencies: [
        "UserDefaultsDependency"
      ]
    ),

    .target(
      name: "UserNotificationsDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesAdditionsBasics", package: "Basics"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .testTarget(
      name: "UserNotificationsDependencyTests",
      dependencies: [
        "UserNotificationsDependency"
      ]
    ),
  ]
)

/// Temporary dependencies
// define("CryptoDependency")
// define("KeyChainDependency")
// define("Version")?

// define("Dependency", dependencies: "Base", testingDependencies: "TestSupport")
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

func addIndividualProducts() {
  package.products.append(contentsOf: [
    .library(name: "ApplicationDependency", targets: ["ApplicationDependency"]),
    .library(name: "AssertionDependency", targets: ["AssertionDependency"]),
    .library(name: "AccessibilityDependency", targets: ["AccessibilityDependency"]),
    .library(name: "BundleDependency", targets: ["BundleDependency"]),
    .library(name: "CodableDependency", targets: ["CodableDependency"]),
    .library(name: "CompressionDependency", targets: ["CompressionDependency"]),
    .library(name: "DataDependency", targets: ["DataDependency"]),
    .library(name: "DeviceDependency", targets: ["DeviceDependency"]),
    .library(name: "LoggerDependency", targets: ["LoggerDependency"]),
    .library(name: "NotificationCenterDependency", targets: ["NotificationCenterDependency"]),
    .library(name: "PathDependency", targets: ["PathDependency"]),
    .library(name: "PersistentContainerDependency", targets: ["PersistentContainerDependency"]),
    .library(name: "ProcessInfoDependency", targets: ["ProcessInfoDependency"]),
    .library(name: "UserDefaultsDependency", targets: ["UserDefaultsDependency"]),
    .library(name: "UserNotificationsDependency", targets: ["UserNotificationsDependency"]),
  ])
}
//addIndividualProducts()

//for target in package.targets {
//  target.swiftSettings = target.swiftSettings ?? []
//  target.swiftSettings?.append(
//    .unsafeFlags([
//      "-Xfrontend", "-warn-concurrency",
//      "-Xfrontend", "-enable-actor-data-race-checks",
//      //      "-enable-library-evolution",
//    ])
//  )
//}

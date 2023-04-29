# ``DependenciesAdditions``

Additional dependencies for Pointfree.co's "Dependencies" library.

[Dependencies](https://github.com/pointfreeco/swift-dependencies) is a fantastic library that helps 
you to manage your dependencies in a similar fashion SwiftUI handles its `Environment`. 
`Dependencies` already ships with many built-in fundamental dependencies, like `clock`, `uuid`, 
`date`, etc.

"Dependencies Additions" intends to extend these core dependencies, and provide coherent and 
testable implementations to many additional dependencies that are commonly needed when developing 
on Apple's platforms.

## Additional dependencies

"Dependencies Additions" adds the following new ``DependencyValues`` keypaths:

| Module                          | `DependencyValues`' KeyPaths         |
|---------------------------------|--------------------------------------|
| `AccessibilityDependency`       | `\.accessibility`                    |
| `ApplicationDependency`         | `\.application`                      |
| `AssertionDependency`           | `\.assert` and `\.assertionFailure`  |
| `BundleDependency`              | `\.bundleInfo`                       |
| `CodableDependency`             | `\.encode` and `\.decode`            |
| `CompressionDependency`         | `\.compress` and `\.decompress`      |
| `DataDependency`                | `\.dataReader` and `\.dataWriter`    |
| `DeviceDependency`              | `\.device` and `\.deviceCheckDevice` |
| `LoggerDependency`              | `\.logger`                           |
| `NotificationCenterDependency`  | `\.notificationCenter`               |
| `PathDependency`                | `\.path`                             |
| `PersistentContainerDependency` | `\.persitentContainer`               |
| `ProcessInfoDependency`         | `\.processInfo`                      |
| `UserDefaultsDependency`        | `\.userDefaults`                     |
| `UserNotificationsDependency`   | `\.userNotificationCenter`           |

You can import the umbrella module `DependenciesAdditions` or each module independently according
to your coding style.

You can use Xcode's "build documentation" command to generate the documentation for individual 
modules.

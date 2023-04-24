# ``DependenciesAdditions``

Additional dependencies for Pointfree.co's "Dependencies" library.

[Dependencies](https://github.com/pointfreeco/swift-dependencies) is a fantastic library that helps you to manage your dependencies in a similar fashion SwiftUI handles its `Environment`. `Dependencies` already ships with many built-in fundamental dependencies, like `clock`, `uuid`, `date`, etc.

"Dependencies Additions" intends to extend these core dependencies, and provide coherent and testable implementations to many additional dependencies that are commonly needed when developing on Apple's platforms.

## Additional dependencies

"Dependencies Additions" adds the following new ``DependencyValues``:

```swift
@Dependency(\.accessibility) var accessibility
@Dependency(\.application) var application
@Dependency(\.assertionDependency) var assertionDependency
@Dependency(\.bundleInfo) var bundleInfo
@Dependency(\.codable) var codable
@Dependency(\.compression) var compression
@Dependency(\.dataReader) var dataReader
@Dependency(\.logger) var logger
@Dependency(\.notificationCenter) var notificationCenter
@Dependency(\.persistentContainer) var persistentContainer
@Dependency(\.userDefaults) var userDefaults
@Dependency(\.userNotificationCenter) var userNotificationCenter
@Dependency(\.path) var path
@Dependency(\.processInfo) var processInfo
@Dependency(\.device) var device
```

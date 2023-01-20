# Dependencies Additions

A companion library to Point-Free's [`swift-dependencies`](https://github.com/pointfreeco/swift-dependencies) that provides higher-level dependencies.

[![CI](https://github.com/tgrapperon/swift-dependencies-additions/actions/workflows/ci.yml/badge.svg)](https://github.com/tgrapperon/swift-dependencies-additions/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-dependencies-additions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tgrapperon/swift-dependencies-additions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-dependencies-additions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tgrapperon/swift-dependencies-additions)

## On the menu
[Dependencies](https://github.com/pointfreeco/swift-dependencies) is a fantastic library that helps you to manage your dependencies in a similar fashion SwiftUI handles its `Environment`. `Dependencies` already ships with many built-in fundamental dependencies, like `clock`, `uuid`, `date`, etc.

"Dependencies Additions" intends to extend these core dependencies, and provide coherent and testable implementations to many additional dependencies that are commonly needed when developing on Apple's platforms.

The library currently proposes a few low-level dependencies to interface with:
- `Accessibility`, an abstraction over `UIAccessibility`;
- `Application`, an abstraction over `UIApplication.shared`;
- `BundleInfo`, an abstraction over the app's `info.plist`;
- `Codable`, to encode/decode `Codable` types to `Data`;
- `Compression`, to compress/decompress `Data` using the `Compression framework;
- `DataReader/Writer`, to read/write `Data` from `URL`'s (an idea from [David Roman](https://github.com/davdroman));
- `Logger`, that exposes a privacy-aware `Logger` instance;
- `NotificationCenter`;
- `PersistentContainer`, that abstracts a CoreData `NSPersistentContainer`;
- `UserDefaults`;
- `UserNotificationCenter`;
- `Path`, a generalized collection of `AnyHashable`, to which you can push and pop identifiers to contextualize your models;
- `ProcessInfo`;
- `Device` (`UIDevice`, `WKInterfaceDevice`, `DCDevice`,…).

It also ships with more experimental and higher-level abstractions for:
- `AppStorage`, which proposes a `@Dependency.AppStorage` property wrapper that mimics `SwiftUI`s `@AppStorage`, but usable from your model and or any concurrent context.
- `CoreData`, which attempts to expose a safe and convenient interface to your `CoreData` graph (WIP).
- `Notification`, that exposes `NotificationCenter`'s notifications under the form of typed and controllable `AsyncSequence`s.
- `SwiftUI`'s `Environment`, which republishes `SwiftUI`'s `Environment` values in your model.

These higher-level dependencies are currently all experimental, and their targets are named with underscores.
They could eventually evolve out of `Dependencies Additions` into dedicated repositories if their size/behavior justifies it.

This library also proposes a few direct extensions to "core" dependencies like some new date and random numbers generators, as well as some tools to help mixing `AsyncSequence`s with Combine for example.

This list is preliminary, and many new dependencies will be added to this library in the upcoming weeks.
If you need one specific dependency, feel free to open a discussion, so we can find the better way it can
integrate with the other ones.

## How to use `Dependencies Additions`?

This library proposes many heterogeneous dependencies. Having all of them bundled under the same repository has many benefits:
- All the dependencies API's are designed coherently, with predictable behaviors.
- Some dependencies are too small to justify a fully-fledged repository. Having all of them at hand helps with discovery.
- Some dependencies depend on other dependencies, and it would be much more complex to manage if each project is in a dedicated repository.

You can simply import `DependenciesAdditions` umbrella product to get access to all the dependencies at once 
If you prefer more control, and because each dependency of them is self-contained in its own module, you can import only the ones that you need "à la carte", on a file-by-file basis.

### Using Xcode packages dependencies:

Add the `swift-dependencies-additions` package, and only select "DependenciesAdditions" product

### Using SwiftPM:

In the `dependencies` section, add:
```swift
.package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "0.1.0")
```
In each module you need access to these dependencies, add:
```swift
.target(
  name: "MyModule",
  dependencies: [
    .product(name: "DependenciesAdditions", package: "swift-dependencies-additions")
  ]
),
```
This gives access to all non-underscored dependencies. Experimental dependencies need to be imported individually. For example:
```swift
.product(name: "_AppStorage", package: "swift-dependencies-additions")
```

## A quick tour of the dependencies

We present here a few of the dependencies currently shipping with the library.
If you're more interested in experimental abstractions like `AppStorage` or typed `Notification`, you can directly jump to the [Higher-level dependencies](#higher-level-dependencies) section.

### Accessibility

An abstraction over `UIAccessibility` that you can use to monitor the accessibility state of
your app's instance.

For example:
```swift
class Model {
  @Dependency(\.accessibility) var accessibility

  @MainActor
  func isSystemFontBold() -> Bool {
    self.accessibility.isBoldTextEnabled
  }
}
```

And then, when testing:
```swift
@MainActor 
func testIsSystemBold() {
  let model = withDependencies {
    $0.accessibility.$isBoldTextEnabled = true
  } operation: { Model() }
  XCTAssertTrue(model.isSystemFontBold())
} 
```

### Application

An abstraction over `UIApplication` that you can use to communicate with your app's instance.

For example:
```swift
class Model {
  @Dependency(\.application) var application

  func setAlternateIcon(name: String) async throws {
    try await self.application.setAlternateIconName(name)
  }
}
```

And then, when testing:
```swift
@MainActor 
func testAlternateIconIsSet() async throws -> Void {
  var alternateIconName = LockIsolated("")
  let model = withDependencies {
    $0.application.$setAlternateIcon = { name in
      alternateIconName.withValue { $0 = name }
    }
  } operation: { Model() }
  try await model.setAlternateIcon(name: "blueprint")
  XCTAssertEqual(alternateIconName.value, "blueprint")
} 
```

### BundleInfo

This simple dependency exposes a `BundleInfo` type that allows to simply retrieve a few `info.plist`-related fields, like the `bundleIdentifier` or the app's `version`. 

For example:
```swift
@Dependency(\.bundleInfo.bundleIdentifier) var bundleIdentifier
```
As this value is often used to prefix identifiers, having this value exposed as a dependency allows you to control it at a distance when testing for example.

### Codable
The library exposes two dependencies to help with coding or decoding your `Codable` types.
```swift
@Dependency(\.encode) var encode
@Dependency(\.decode) var decode

struct Point: Codable {
  var x: Double
  var y: Double
}

let point = Point(x: 12, y: 35)
let encoded = try encode(point) // A `Data` value
let decoded = try decode(Point.self, from: encoded) // A `Point` value
```
As you can see, the API is very similar to JSON or PropertyList encoder and decoder.

By default, `encode` and `decode` are producing/consuming `JSON` data.

### Compression
In the same fashion as `encode` and `decode`, the library exposes two
dependencies to compress and decompress `Data`, using Apple's Compression framework:
```swift
@Dependency(\.compress) var compress
@Dependency(\.decompress) var decompress

let uncompressed = "Lorem ipsum dolor sit amet".data(using: .utf8)!
let compressed = try compress(uncompressed, using: .lzfse)
let decompressed = try decompress(compressed, using: .lzfse)
```
They can also be called from async contexts, where a more efficient variant is used:
```swift
let compressed = try await compress(uncompressed)
let decompressed = try await decompress(compressed)
```

By default, `compress` and `decompress` are using the `.zlib` algorithm.

### Logger
This dependency exposes a privacy-aware `Logger` instance.
@Dependency(\.logger) var logger

You can simply use it as
```swift
logger.log(level: .info, "User with id: \(userID, privacy: .private) did purchase a smoothie")
```
You can simply create a subsystem using the provided subscript:
```swift
@Dependency(\.logger["Transactions"]) var transactionsLogger
```

### PersistentContainer
A `NSPersistentContainer` that exposes Core Data `NSManagedObjectContext`s. You can use it as a 
basis for more elaborate abstractions.
```swift
@Dependency(\.persistentContainer) var persistentContainer
```
By default, the preview version is an `in-memory` variant, and you can easily setup mocks for your SwiftUI previews:
```swift
var previews: some View {
  let model = withDependencies {
    $0.persistentContainer = .default(inMemory: true).with { context in
      let smoothie = Smoothie(context: context)
      smoothie.flavor = "Banana"
    }
  }
  SmoothieView(model: model)
}
```

### ProcessInfo
A simple abstraction over `ProcessInfo` that allows to retrieve low-level information on the system.
```swift
@Dependency(\.processInfo.thermalState) var thermalState

if thermalState == .critical {
  self.disableFancyAnimations()
}
```
Because it's a dependency, you can test it very easily without having to modify your model.

### UserDefaults
An abstraction over `UserDefaults`, where you can read and save from the user preferences.
The library exposes the same types as SwiftUI's AppStorage, so you can simply store and retrieve 
your data. 
```swift
@Dependency(\.userDefaults) var userDefaults

userDefaults.save(true, forKey: "hasUserPassedOnboarding")
```
With one line of code, you can make your whole app write to your app group user defaults, an in-memory version for testing, or even to `NSUbiquitousKeyValueStore` that syncs user preferences over iCloud.

You can also give a spin to the more powerful [`_AppStorage`](#appstorage) dependency that is built on top of `\.userDefaults`, and which allows to seamlessly observe and assign user preferences with an API similar to SwiftUI's `AppStorage` (with which it can interoperate).

### Other dependencies
Many other dependencies are available, like `UserNotifications` to display notifications, `Device` to interact with `UIDevice` or `WKInterfaceDevice`, `Path` to contextualize your model's tree, a clicking `DateGenerator` that is controlled by a `Clock` (that you can control itself), etc.

Of course, this is only the beginning and many other dependencies will be added in the upcoming weeks.
We strongly feel that the larger the dependencies spectrum is, the more you will use them, and the more your code will be testable and structured.

## Higher-level dependencies
The library proposes a few experimental higher-level dependencies. They are currently "underscored", meaning that their APIs are not finalized. They may be extracted into their own library in the future.

### AppStorage
```swift
@Dependency.AppStorage("username") var username: String = "Anonymous"
```
The API follows SwiftUI's `AppStorage`, but is backed by `@Dependency(\.userDefaults)`.
It can operate within your model and be accessed from async contexts. If the same `key`s are used, it can inter-operate with `SwiftUI`'s own `AppStorage`.
The projected value is an `AsyncStream<Value>` of this user preference's values. They can be observed from any async context:
```swift
@Dependency.AppStorage("isSoundEnabled") var isSoundEnabled: Bool = false

for await isSoundEnabled in $isSoundEnabled {
  await isSoundEnabled ? audioEngine.start() : audioEngine.stop()
}
```
### Notifications
This dependency allows exposing `Notification`s as typed `AsyncSequence`s.
```swift
extension Notifications {
  /// A typed `Notification` that publishes the current device's battery level.
  @MainActor
  public var batterLevelDidChange: SystemNotificationOf<Float> {
    .init(UIDevice.batteryLevelDidChangeNotification) { notification in
      @Dependency(\.device.batteryLevel) var level;
      return level
    }
  }
}
```
You can then expose this notification with a dedicated property wrapper:
```swift
@Dependency.Notification(\.batteryLevelDidChange) var batteryLevel
```
The exposed value is an async sequence of `Float` representing the `batteryLevel`:
```swift
for await level in batteryLevel {
  if level < 0.2 {
    self.isLowPowerModeEnabled = true
  }
}
```
### SwiftUI Environment
This dependency brings SwiftUI's `Environment` into your model:
```swift
@Dependency.Environment(\.colorScheme) var colorScheme
@Dependency.Environment(\.dismiss) var dismiss
```
Then, in any `View`, you use the `.observeEnvironmentAsDependency(\.colorScheme)` modifier to 
bubble up this value into the model:
```swift
HStack { … }
  .observeEnvironmentAsDependency(\.colorScheme)
  .observeEnvironmentAsDependency(\.dismiss)
```
In the example above, `self.colorScheme` is a `ColorScheme?`, and `self.dismissAction` is a 
`DismissAction?`. Both are optional because they're conditioned by the existence of the `View`, and
they can become `nil` again if this view goes away.
You can observe their value through the projected value which is an `AsyncSequence` of the wrapped
value:
```swift
for await colorScheme in self.$colorScheme.compactMap{ $0 }.dropFirst() {
  self.logger.info("ColorScheme did change: \(colorScheme)")
}
```
### Core Data (WIP)
This dependency is still WIP because we would like to harden the API to avoid common pitfalls with CoreData.
But you can get an excerpt of it in the CoreData CaseStudy!

## What's next?

This is only the beginning! There are many other dependencies to implement: `Speech`, `Vision`, `KeyChain`, etc…
The only rule, for now, is that it shouldn't require a third-party dependency itself, and should work
on `Apple` or `Linux` platforms out of the box.
If you want to contribute a dependency, feel free to open a thread in the discussions!

## Installation

You can add DependenciesAdditions to an Xcode project by adding it to your project as a package.
```
https://github.com/tgrapperon/swift-dependencies-additions
```

If you want to use DependenciesAdditions in a SwiftPM project, it's as simple as adding it to your Package.swift:
```swift
dependencies: [
  .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "0.1.0")
]
```

## License
This library is released under the MIT license. See LICENSE for details.

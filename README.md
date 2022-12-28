# Dependencies Additions

A companion library to Point-Free's `swift-dependencies` that provides higher-level dependencies.

## On the menu
`Dependencies` is a fantastic library that helps managing your app's dependencies in a similar fashion SwiftUI handles its `Environment`.

`Dependencies` already ships with many dependencies, like `clock`, `uuid`, `date`, etc., but its fundamental nature prevents it to ship with too many built-in dependencies.

//`Dependencies Additions` intends to bridge the gap between these very fundamental dependencies and every-day development on Apple's platforms.

As of today, the library propose a few low-level additional dependencies to interface with:
- `BundleInfo`
- `Codable`
- `Compression`
- `Logger`
- `PersistentContainer`
- `UserDefaults`

It also ships with more experimental and higher level abstractions for:
- `AppStorage`, that proposes an `@Dependency.AppStorage` which mimics `SwiftUI`s `@AppStorage`, but usable from your model and or any concurrent context.
- `CoreData`, [TODO]
- `Notifications`, that exposes notifications under the form of typed `AsyncSequence`s.
- `SwiftUI`'s `Environment`, that republishes `SwiftUI`'s `Environment` values in your model.

Each dependency is self contained in its own module, so you can import only the ones that you need "à la carte".

## Additional Dependencies

### `BundleInfo`

This very simple dependency exposes a `BundleInfo` type that allows to simply retrieve a few `Bundle`-related fields, like the `bundleIdentifier` or the app's `version`. 

For example:
```swift
@Dependency(\.bundleInfo.bundleIdentifier) var bundleIdentifier
```
As this value is often used to prefix identifiers, having this value exposed as a dependency allows you control it at distance when testing for example.

### Codable
### Compression
### Logger
### PersistentContainer
### UserDefaults
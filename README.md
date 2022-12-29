# WIP

TODO: Underscore _CoreData, _AppStorage, _Notification and _SwiftUI

# Dependencies Additions

A companion library to Point-Free's `swift-dependencies` that provides higher-level dependencies.

## On the menu
`Dependencies` is a fantastic library that helps managing your app's dependencies in a similar fashion SwiftUI handles its `Environment`.

TODO: Reword this
// `Dependencies` already ships with many dependencies, like `clock`, `uuid`, `date`, etc., but its fundamental nature prevents it to ship with too many built-in dependencies.
// `Dependencies Additions` intends to bridge the gap between these very fundamental dependencies and every-day development on Apple's platforms.

The library proposes a few low-level additional dependencies to interface with:
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

This very simple dependency exposes a `BundleInfo` type that allows to simply retrieve a few `info.plist`-related fields, like the `bundleIdentifier` or the app's `version`. 

For example:
```swift
@Dependency(\.bundleInfo.bundleIdentifier) var bundleIdentifier
```
As this value is often used to prefix identifiers, having this value exposed as a dependency allows you control it at distance when testing for example.

### Codable
The library exposes two dependencies to helps with coding or decoding of your `Codable` types.
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

By default, encode and decode are producing/consuming `JSON` data.

### Compression
### Logger
### PersistentContainer
### UserDefaults

import Dependencies
import DependenciesAdditions
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var bundleInfo: BundleInfo {
    get { self[BundleInfo.self] }
    set { self[BundleInfo.self] = newValue }
  }
}

// TODO: Add infoDictionary

/// A type that exposes a few fields from some `Bundle`'s `info.plist`.
public struct BundleInfo: Sendable {
  /// A unique identifier for a bundle.
  @LazyProxy public var bundleIdentifier: String
  /// A user-visible short name for the bundle.
  @LazyProxy public var name: String
  /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
  @LazyProxy public var displayName: String
  /// A replacement for the app name in text-to-speech operations.
  @LazyProxy public var spokenName: String
  /// The release or version number of the bundle.
  @LazyProxy public var shortVersion: String
  /// The version of the build that identifies an iteration of the bundle.
  @LazyProxy public var version: String
  
  /// Creates a ``BundleInfo`` value.
  /// - Parameters:
  ///   - bundleIdentifier: A unique identifier for a bundle.
  ///   - name: A user-visible short name for the bundle.
  ///   - displayName: The user-visible name for the bundle.
  ///   - spokenName: A replacement for the app name in text-to-speech operations.
  ///   - shortVersion: The release or version number of the bundle.
  ///   - version: The version of the build that identifies an iteration of the bundle.
  public init(
    bundleIdentifier: @escaping () -> String,
    name: @escaping () -> String,
    displayName: @escaping () -> String,
    spokenName: @escaping () -> String,
    shortVersion: @escaping () -> String,
    version: @escaping () -> String
  ) {
    self._bundleIdentifier = .init(bundleIdentifier)
    self._name = .init(name)
    self._displayName = .init(displayName)
    self._spokenName = .init(spokenName)
    self._shortVersion = .init(shortVersion)
    self._version = .init(version)
  }
}

extension BundleInfo {
  public init(bundle: Bundle) {
    let get: (String) -> () -> String = { key in
      { bundle.object(forInfoDictionaryKey: key) as? String ?? "" }
    }
    self = BundleInfo(
      bundleIdentifier: get("CFBundleIdentifier"),
      name: get("CFBundleName"),
      displayName: get("CFBundleDisplayName"),
      spokenName: get("CFBundleSpokenName"),
      shortVersion: get("CFBundleShortVersionString"),
      version: get("CFBundleVersion")
    )
  }
}

extension BundleInfo: DependencyKey {
  static public var liveValue: BundleInfo {
    BundleInfo(bundle: .main)
  }
  static public var testValue: BundleInfo {
    .unimplemented
  }
}

extension BundleInfo {
  static var unimplemented: BundleInfo {
    BundleInfo(
      bundleIdentifier: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.bundleInfo.bundleIdentifier)"#),
      name: XCTestDynamicOverlay.unimplemented(#"Unimplemented: @Dependency(\.bundleInfo.name)"#),
      displayName: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.bundleInfo.displayName)"#),
      spokenName: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.bundleInfo.spokenName)"#),
      shortVersion: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.bundleInfo.shortVersion)"#),
      version: XCTestDynamicOverlay.unimplemented(
        #"Unimplemented: @Dependency(\.bundleInfo.version)"#)
    )
  }
}

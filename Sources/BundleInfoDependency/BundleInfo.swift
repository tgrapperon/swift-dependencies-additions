import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var bundleInfo: BundleInfo {
    get { self[BundleInfo.self] }
    set { self[BundleInfo.self] = newValue }
  }
}

public struct BundleInfo: Sendable, Hashable {
  /// Creates a ``BundleInfo`` value.
  /// - Parameters:
  ///   - bundleIdentifier: A unique identifier for a bundle.
  ///   - name: A user-visible short name for the bundle.
  ///   - displayName: The user-visible name for the bundle.
  ///   - spokenName: A replacement for the app name in text-to-speech operations.
  ///   - shortVersion: The release or version number of the bundle.
  ///   - version: The version of the build that identifies an iteration of the bundle.
  public init(
    bundleIdentifier: @autoclosure () -> String,
    name: @autoclosure () -> String,
    displayName: @autoclosure () -> String,
    spokenName: @autoclosure () -> String,
    shortVersion: @autoclosure () -> String,
    version: @autoclosure () -> String
  ) {
    self.bundleIdentifier = bundleIdentifier()
    self.name = name()
    self.displayName = displayName()
    self.spokenName = spokenName()
    self.shortVersion = shortVersion()
    self.version = version()
  }

  /// A unique identifier for a bundle.
  public var bundleIdentifier: String

  /// A user-visible short name for the bundle.
  public var name: String
  /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
  public var displayName: String
  /// A replacement for the app name in text-to-speech operations.
  public var spokenName: String

  /// The release or version number of the bundle.
  public var shortVersion: String
  /// The version of the build that identifies an iteration of the bundle.
  public var version: String
}

extension BundleInfo {
  public init(bundle: Bundle) {
    let get: (String) -> String = {
      bundle.object(forInfoDictionaryKey: $0) as? String ?? ""
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
    XCTFail(#"Unimplemented: @Dependency(\.bundleInfo)"#)
    return BundleInfo(
      bundleIdentifier: "",
      name: "",
      displayName: "",
      spokenName: "",
      shortVersion: "",
      version: ""
    )
  }
}

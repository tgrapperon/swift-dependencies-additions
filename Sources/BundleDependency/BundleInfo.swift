import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import IssueReporting

extension DependencyValues {
  public var bundleInfo: BundleInfo {
    get { self[BundleInfo.self] }
    set { self[BundleInfo.self] = newValue }
  }
}

// TODO: Add infoDictionary

/// A type that exposes a few fields from some `Bundle`'s `info.plist`.
public struct BundleInfo: Sendable, ConfigurableProxy {
  public struct Implementation: Sendable {
    @ReadOnlyProxy public var bundleIdentifier: String
    @ReadOnlyProxy public var name: String
    @ReadOnlyProxy public var displayName: String
    @ReadOnlyProxy public var spokenName: String
    @ReadOnlyProxy public var shortVersion: String
    @ReadOnlyProxy public var version: String
  }

  @_spi(Internals) public var _implementation: Implementation

  /// A unique identifier for a bundle.
  public var bundleIdentifier: String {
    self._implementation.bundleIdentifier
  }
  /// A user-visible short name for the bundle.
  public var name: String {
    self._implementation.name
  }
  /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
  public var displayName: String {
    self._implementation.displayName
  }
  /// A replacement for the app name in text-to-speech operations.
  public var spokenName: String {
    self._implementation.spokenName
  }
  /// The release or version number of the bundle.
  public var shortVersion: String {
    self._implementation.shortVersion
  }
  /// The version of the build that identifies an iteration of the bundle.
  public var version: String {
    self._implementation.version
  }
}

extension BundleInfo {
  /// Creates a ``BundleInfo`` value.
  /// - Parameters:
  ///   - bundleIdentifier: A unique identifier for a bundle.
  ///   - name: A user-visible short name for the bundle.
  ///   - displayName: The user-visible name for the bundle.
  ///   - spokenName: A replacement for the app name in text-to-speech operations.
  ///   - shortVersion: The release or version number of the bundle.
  ///   - version: The version of the build that identifies an iteration of the bundle.
  public init(
    bundleIdentifier: @escaping @autoclosure @Sendable () -> String,
    name: @escaping @autoclosure @Sendable () -> String,
    displayName: @escaping @autoclosure @Sendable () -> String,
    spokenName: @escaping @autoclosure @Sendable () -> String,
    shortVersion: @escaping @autoclosure @Sendable () -> String,
    version: @escaping @autoclosure @Sendable () -> String
  ) {
    self._implementation = .init(
      bundleIdentifier: .init(bundleIdentifier()),
      name: .init(name()),
      displayName: .init(displayName()),
      spokenName: .init(spokenName()),
      shortVersion: .init(shortVersion()),
      version: .init(version())
    )
  }
}

extension BundleInfo {
  public init(bundle: @escaping @autoclosure @Sendable () -> Bundle) {
    let isolated = LockIsolated(bundle())
    let get: @Sendable (String) -> () -> String = { key in
      {
        isolated.withValue {
          $0.object(forInfoDictionaryKey: key) as? String ?? ""
        }
      }
    }
    self = BundleInfo(
      bundleIdentifier: get("CFBundleIdentifier")(),
      name: get("CFBundleName")(),
      displayName: get("CFBundleDisplayName")(),
      spokenName: get("CFBundleSpokenName")(),
      shortVersion: get("CFBundleShortVersionString")(),
      version: get("CFBundleVersion")()
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
      _implementation: .init(
        bundleIdentifier: .unimplemented(
          #"@Dependency(\.bundleInfo.bundleIdentifier)"#, placeholder: ""),
        name: .unimplemented(#"@Dependency(\.bundleInfo.name)"#, placeholder: ""),
        displayName: .unimplemented(#"@Dependency(\.bundleInfo.displayName)"#, placeholder: ""),
        spokenName: .unimplemented(#"@Dependency(\.bundleInfo.spokenName)"#, placeholder: ""),
        shortVersion: .unimplemented(#"@Dependency(\.bundleInfo.shortVersion)"#, placeholder: ""),
        version: .unimplemented(#"@Dependency(\.bundleInfo.version)"#, placeholder: "")
      )
    )
  }
}

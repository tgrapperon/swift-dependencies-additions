import Foundation

extension UserDefaults.Dependency {
  /// Returns the Boolean value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Boolean value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func bool(forKey key: String) -> Bool? {
    self._get(key, Bool.self) as? Bool
  }

  /// Sets the value of the specified default key to the specified Boolean value.
  /// - Parameters:
  ///   - value: The Boolean value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Bool?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Data value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Data value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func data(forKey key: String) -> Data? {
    self._get(key, Date.self) as? Data
  }

  /// Sets the value of the specified default key to the specified Data value.
  /// - Parameters:
  ///   - value: The Data value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Data?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Double value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Double value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func double(forKey key: String) -> Double? {
    self._get(key, String.self) as? Double
  }

  /// Sets the value of the specified default key to the specified Double value.
  /// - Parameters:
  ///   - value: The Double value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Double?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the Int value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Int value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func integer(forKey key: String) -> Int? {
    self._get(key, Int.self) as? Int
  }

  /// Sets the value of the specified default key to the specified Int value.
  /// - Parameters:
  ///   - value: The Int value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Int?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the String value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The String value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func string(forKey key: String) -> String? {
    self._get(key, String.self) as? String
  }

  /// Sets the value of the specified default key to the specified String value.
  /// - Parameters:
  ///   - value: The String value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: String?, forKey key: String) {
    self._set(value, key)
  }

  /// Returns the URL value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The URL value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func url(forKey key: String) -> URL? {
    self._get(key, URL.self) as? URL
  }

  /// Sets the value of the specified default key to the specified URL value.
  /// - Parameters:
  ///   - value: The URL value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: URL?, forKey key: String) {
    self._set(value, key)
  }

  /// Removes the specified for the specified key. You can alternatively set a `nil` value using
  /// any typed ``set(_:forKey:)`` overload.
  public func removeValue(forKey key: String) {
    self._set(nil, key)
  }
}

extension UserDefaults.Dependency {
  /// Returns a RawRepresentable value `R` associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The RawRepresentable value `R` associated with the specified key, or `nil` if there
  /// is no value associated to `key`, or if `R` cannot be built from the associated value.
  public func rawRepresentable<R: RawRepresentable>(forKey key: String) -> R?
  where R.RawValue == String {
    self.string(forKey: key).flatMap(R.init(rawValue:))
  }

  /// Sets the value of the specified default key to the specified RawRepresentable `R` value.
  /// - Parameters:
  ///   - value: The RawRepresentable `R` value to store in the user's defaults store. If the value
  ///   is `nil`, the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set<R: RawRepresentable>(_ value: R?, forKey key: String) where R.RawValue == String {
    self._set(value?.rawValue, key)
  }

  /// Returns a RawRepresentable value `R` associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The RawRepresentable value `R` associated with the specified key, or `nil` if there
  /// is no value associated to `key`, or if `R` cannot be built from the associated value.
  public func rawRepresentable<R: RawRepresentable>(forKey key: String) -> R?
  where R.RawValue == Int {
    self.integer(forKey: key).flatMap(R.init(rawValue:))
  }

  /// Sets the value of the specified default key to the specified RawRepresentable `R` value.
  /// - Parameters:
  ///   - value: The RawRepresentable `R` value to store in the user's defaults store. If the value
  ///   is `nil`, the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set<R: RawRepresentable>(_ value: R?, forKey key: String) where R.RawValue == Int {
    self._set(value?.rawValue, key)
  }
}

// NS Extensions
extension UserDefaults.Dependency {
  /// Returns the Date value associated with the specified key.
  /// - Parameter key: A key in the current user defaults store.
  /// - Returns: The Boolean value associated with the specified key, or `nil` if there is no value
  /// associated to `key`
  public func date(forKey key: String) -> Date? {
    self._get(key, Date.self) as? Date
  }

  /// Sets the value of the specified default key to the specified Date value.
  /// - Parameters:
  ///   - value: The Date value to store in the user's defaults store. If the value is `nil`,
  ///   the associated value will be removed from the store.
  ///   - key: The key with which to associate the value.
  public func set(_ value: Date?, forKey key: String) {
    self._set(value, key)
  }
}

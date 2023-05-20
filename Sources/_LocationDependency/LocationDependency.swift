#if canImport(CoreLocation)
  @preconcurrency import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import LocationManagerDependency

  extension DependencyValues {
    /// An abstraction of `CLLocationManager`, the central object for managing
    /// notification-related activities for your app or app extension.
    public var location: LocationClient {
      get { self[LocationClient.self] }
      set { self[LocationClient.self] = newValue }
    }
  }

  extension LocationClient: DependencyKey {
    public static var liveValue: LocationClient { .system }
    public static var testValue: LocationClient { .unimplemented }
    public static var previewValue: LocationClient { .system }
  }

  public struct LocationClient: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      // TODO: Try to add `@MainActor`
      @FunctionProxy public var getLocation: @Sendable () async throws -> CLLocationCoordinate2D
    }

    @_spi(Internals) public var _implementation: Implementation
  }




enum LocationError: Error {
  case noLocation, notAuthorized(CLAuthorizationStatus), error(CLError)
}

enum DelegateError: Swift.Error {
  case deinitialized
}


final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  private var locationContinuations: [CheckedContinuation<CLLocationCoordinate2D, any Error>] = []
  private var authorizationContinuations: [CheckedContinuation<CLAuthorizationStatus, Never>] = []

  deinit {
    while !self.locationContinuations.isEmpty {
      self.locationContinuations.removeFirst().resume(throwing: DelegateError.deinitialized)
    }
  }

  func registerLocationContinuation(_ continuation: CheckedContinuation<CLLocationCoordinate2D, any Error>) {
    self.locationContinuations.append(continuation)
  }
  func registerAuthorizationContinuation(_ continuation: CheckedContinuation<CLAuthorizationStatus, Never>) {
    self.authorizationContinuations.append(continuation)
  }

  private func locationReceived(_ res: Result<CLLocationCoordinate2D, LocationError>) -> Void {
    while !self.locationContinuations.isEmpty {
      self.locationContinuations.removeFirst().resume(with: res)
    }
  }

  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      self.locationReceived(.success(location.coordinate))
    } else {
      self.locationReceived(.failure(LocationError.noLocation))
    }
  }

  func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    self.locationReceived(.failure(LocationError.error(error as! CLError)))
  }

  @available(macOS 11, *)
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    while !self.authorizationContinuations.isEmpty {
      self.authorizationContinuations.removeFirst().resume(returning: status)
    }
  }

  @available(macOS, deprecated: 11)
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    while !self.authorizationContinuations.isEmpty {
      self.authorizationContinuations.removeFirst().resume(returning: status)
    }
  }
}

extension CLAuthorizationStatus {
  var _isAuthorized: Bool {
    switch self {
    case .authorized, .authorizedAlways, .authorizedWhenInUse:
      return true
    case .denied, .notDetermined, .restricted:
      return false
    @unknown default:
      return false
    }
  }
}

extension LocationClient {
  static var system: LocationClient {
    let locationManagerDelegate = LocationManagerDelegate()

    let requestWhenInUseAuthorization = { @Sendable @MainActor in
      let status: CLAuthorizationStatus
      if #available(macOS 11.0, *) {
        @Dependency(\.locationManager.authorizationStatus) var authorizationStatus
        status = authorizationStatus
      } else {
        status = CLLocationManager.authorizationStatus()
      }
      if status._isAuthorized {
        return status
      }

      return await withCheckedContinuation { continuation in
        locationManagerDelegate.registerAuthorizationContinuation(continuation)
        @Dependency(\.locationManager) var locationManager
        locationManager.requestWhenInUseAuthorization()
      }
    }

    let _implementation = Implementation(
      getLocation: .init {
        @Dependency(\.locationManager) var locationManager
        let locationManagerDelegate = LocationManagerDelegate()

        locationManager.delegate = locationManagerDelegate
        locationManager.desiredAccuracy = locationManager.desiredAccuracy
        locationManager.activityType = .fitness

        if !locationManager.authorizationStatus._isAuthorized {
          let status = await requestWhenInUseAuthorization()
          if !status._isAuthorized {
            throw LocationError.notAuthorized(status)
          }
        }

        let location = try await withCheckedThrowingContinuation { continuation in
          locationManagerDelegate.registerLocationContinuation(continuation)
          locationManager.requestLocation()
        }

        // Stop updating location as `requestLocation` starts it.
        // Without this, calling `requestLocation` a second time does nothing.
        //        locationManager.stopUpdatingLocation()

        return location
      }
    )
    return LocationClient(_implementation: _implementation)
  }

  static var preview: LocationClient {
    let authorized: CLAuthorizationStatus
#if os(macOS)
    authorized = .authorized
#else
    authorized = .authorizedAlways
#endif

    return LocationClient(
      authorizationStatus: { authorized },
      requestWhenInUseAuthorization: { authorized },
      requestAlwaysAuthorization: { authorized },
      getLocation: { _ in
        // Coordinates of the "Dame du Lac" spot in Lisses, France
        CLLocationCoordinate2D(latitude: 48.61739, longitude: 2.41905)
      }
    )
  }

  static let unimplemented = LocationClient(
    authorizationStatus: unimplemented("LocationClient.authorizationStatus", placeholder: .denied),
    requestWhenInUseAuthorization: unimplemented("LocationClient.requestWhenInUseAuthorization", placeholder: .denied),
    requestAlwaysAuthorization: unimplemented("LocationClient.requestAlwaysAuthorization", placeholder: .denied),
    getLocation: unimplemented("LocationClient.getLocation")
  )
}

#endif

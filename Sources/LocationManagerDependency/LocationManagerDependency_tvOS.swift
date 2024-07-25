#if canImport(CoreLocation) && os(tvOS)
  @preconcurrency import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import XCTestDynamicOverlay

  extension LocationManager {
    static var system: Self {
      let manager = CLLocationManager()
      let _implementation = Implementation(
        accuracyAuthorization: .init {
          if #available(tvOS 14, *) {
            return manager.accuracyAuthorization
          } else {
            // Before introducing reduced accuracy, systems only authorized precise accuracy
            return CLAccuracyAuthorization.fullAccuracy
          }
        },
        locationServicesEnabled: .init { CLLocationManager.locationServicesEnabled() },
        delegate: .init(
          .init(
            get: { manager.delegate },
            set: { manager.delegate = $0 }
          )),
        requestWhenInUseAuthorization: .init { manager.requestWhenInUseAuthorization() },
        requestTemporaryFullAccuracyAuthorization: .init {
          if #available(tvOS 14, *) {
            return manager.requestTemporaryFullAccuracyAuthorization(
              withPurposeKey: $0, completion: $1)
          } else {
            fatalError(
              "'requestTemporaryFullAccuracyAuthorization(withPurposeKey:completion:)' is unavailable"
            )
          }
        },
        authorizationStatus: .init {
          if #available(tvOS 14, *) {
            return manager.authorizationStatus
          } else {
            return CLLocationManager.authorizationStatus()
          }
        },
        distanceFilter: .init(
          .init(
            get: { manager.distanceFilter },
            set: { manager.distanceFilter = $0 }
          )),
        desiredAccuracy: .init(
          .init(
            get: { manager.desiredAccuracy },
            set: { manager.desiredAccuracy = $0 }
          )),
        stopUpdatingLocation: .init { manager.stopUpdatingLocation() },
        requestLocation: .init { manager.requestLocation() },
        location: .init { manager.location }
      )
      return LocationManager(_implementation: _implementation)
    }
  }

  extension LocationManager {
    static var unimplemented: LocationManager {
      let _implementation = Implementation(
        accuracyAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.accuracyAuthorization)"#,
          placeholder: .reducedAccuracy),
        locationServicesEnabled: .unimplemented(
          #"@Dependency(\.locationManager.locationServicesEnabled)"#,
          placeholder: false),
        delegate: .unimplemented(
          #"@Dependency(\.locationManager.delegate)"#),
        requestWhenInUseAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.requestWhenInUseAuthorization)"#),
        requestTemporaryFullAccuracyAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.requestTemporaryFullAccuracyAuthorization)"#),
        authorizationStatus: .unimplemented(
          #"@Dependency(\.locationManager.authorizationStatus)"#,
          placeholder: .denied),
        distanceFilter: .unimplemented(
          #"@Dependency(\.locationManager.distanceFilter)"#),
        desiredAccuracy: .unimplemented(
          #"@Dependency(\.locationManager.desiredAccuracy)"#),
        stopUpdatingLocation: .unimplemented(
          #"@Dependency(\.locationManager.stopUpdatingLocation)"#),
        requestLocation: .unimplemented(
          #"@Dependency(\.locationManager.requestLocation)"#),
        location: .unimplemented(
          #"@Dependency(\.locationManager.location)"#)
      )
      return LocationManager(_implementation: _implementation)
    }
  }
#endif

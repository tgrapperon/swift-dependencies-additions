#if canImport(CoreLocation) && os(watchOS)
  @preconcurrency import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import XCTestDynamicOverlay

  extension LocationManager {
    static var system: Self {
      let manager = CLLocationManager()
      let _implementation = Implementation(
        headingAvailable: .init { CLLocationManager.headingAvailable() },
        accuracyAuthorization: .init {
          if #available(watchOS 7, *) {
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
        requestAlwaysAuthorization: .init { manager.requestAlwaysAuthorization() },
        requestTemporaryFullAccuracyAuthorization: .init {
          if #available(watchOS 7, *) {
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: $0, completion: $1)
          } else {
            fatalError(
              "'requestTemporaryFullAccuracyAuthorization(withPurposeKey:completion:)' is unavailable"
            )
          }
        },
        authorizationStatus: .init {
          if #available(watchOS 7, *) {
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
        startUpdatingLocation: .init { manager.startUpdatingLocation() },
        stopUpdatingLocation: .init { manager.stopUpdatingLocation() },
        requestLocation: .init { manager.requestLocation() },
        allowsBackgroundLocationUpdates: .init(
          .init(
            get: { manager.allowsBackgroundLocationUpdates },
            set: { manager.allowsBackgroundLocationUpdates = $0 }
          )),
        activityType: .init(
          .init(
            get: { manager.activityType },
            set: { manager.activityType = $0 }
          )),
        startUpdatingHeading: .init { manager.startUpdatingHeading() },
        stopUpdatingHeading: .init { manager.stopUpdatingHeading() },
        dismissHeadingCalibrationDisplay: .init { manager.dismissHeadingCalibrationDisplay() },
        headingFilter: .init(
          .init(
            get: { manager.headingFilter },
            set: { manager.headingFilter = $0 }
          )),
        headingOrientation: .init(
          .init(
            get: { manager.headingOrientation },
            set: { manager.headingOrientation = $0 }
          )),
        location: .init { manager.location },
        heading: .init { manager.heading },
        requestHistoricalLocations: .init {
          if #available(watchOS 9.0, *) {
            manager.requestHistoricalLocations(
              purposeKey: $0, sampleCount: $1, completionHandler: $2)
          } else {
            fatalError(
              "'requestHistoricalLocations(purposeKey:sampleCount:completionHandler:)' is unavailable"
            )
          }
        }
      )
      return LocationManager(_implementation: _implementation)
    }
  }

  extension LocationManager {
    static var unimplemented: LocationManager {
      let _implementation = Implementation(
        headingAvailable: .unimplemented(
          #"@Dependency(\.locationManager.headingAvailable)"#,
          placeholder: false),
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
        requestAlwaysAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.requestAlwaysAuthorization)"#),
        requestTemporaryFullAccuracyAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.requestTemporaryFullAccuracyAuthorization)"#),
        authorizationStatus: .unimplemented(
          #"@Dependency(\.locationManager.authorizationStatus)"#,
          placeholder: .denied),
        distanceFilter: .unimplemented(
          #"@Dependency(\.locationManager.distanceFilter)"#),
        desiredAccuracy: .unimplemented(
          #"@Dependency(\.locationManager.desiredAccuracy)"#),
        startUpdatingLocation: .unimplemented(
          #"@Dependency(\.locationManager.startUpdatingLocation)"#),
        stopUpdatingLocation: .unimplemented(
          #"@Dependency(\.locationManager.stopUpdatingLocation)"#),
        requestLocation: .unimplemented(
          #"@Dependency(\.locationManager.requestLocation)"#),
        allowsBackgroundLocationUpdates: .unimplemented(
          #"@Dependency(\.locationManager.allowsBackgroundLocationUpdates)"#,
          placeholder: false),
        activityType: .unimplemented(
          #"@Dependency(\.locationManager.activityType)"#),
        startUpdatingHeading: .unimplemented(
          #"@Dependency(\.locationManager.startUpdatingHeading)"#),
        stopUpdatingHeading: .unimplemented(
          #"@Dependency(\.locationManager.stopUpdatingHeading)"#),
        dismissHeadingCalibrationDisplay: .unimplemented(
          #"@Dependency(\.locationManager.dismissHeadingCalibrationDisplay)"#),
        headingFilter: .unimplemented(
          #"@Dependency(\.locationManager.headingFilter)"#),
        headingOrientation: .unimplemented(
          #"@Dependency(\.locationManager.headingOrientation)"#),
        location: .unimplemented(
          #"@Dependency(\.locationManager.location)"#),
        heading: .unimplemented(
          #"@Dependency(\.locationManager.heading)"#),
        requestHistoricalLocations: .unimplemented(
          #"@Dependency(\.locationManager.requestHistoricalLocations)"#)
      )
      return LocationManager(_implementation: _implementation)
    }
  }
#endif

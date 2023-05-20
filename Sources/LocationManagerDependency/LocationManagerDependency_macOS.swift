#if canImport(CoreLocation) && os(macOS)
  @preconcurrency import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import XCTestDynamicOverlay

  extension LocationManager {
    static var system: Self {
      let manager = CLLocationManager()
      let _implementation = Implementation(
        significantLocationChangeMonitoringAvailable: .init {
          CLLocationManager.significantLocationChangeMonitoringAvailable()
        },
        headingAvailable: .init { CLLocationManager.headingAvailable() },
        isAuthorizedForWidgetUpdates: .init {
          if #available(macOS 11, *) {
            return manager.isAuthorizedForWidgetUpdates
          } else {
            return false
          }
        },
        accuracyAuthorization: .init {
          if #available(macOS 11, *) {
            return manager.accuracyAuthorization
          } else {
            // Before introducing reduced accuracy, systems only authorized precise accuracy
            return CLAccuracyAuthorization.fullAccuracy
          }
        },
        isMonitoringAvailable: .init { CLLocationManager.isMonitoringAvailable(for: $0) },
        isRangingAvailable: .init { CLLocationManager.isRangingAvailable() },
        locationServicesEnabled: .init { CLLocationManager.locationServicesEnabled() },
        delegate: .init(
          .init(
            get: { manager.delegate },
            set: { manager.delegate = $0 }
          )),
        requestWhenInUseAuthorization: .init { manager.requestWhenInUseAuthorization() },
        requestAlwaysAuthorization: .init { manager.requestAlwaysAuthorization() },
        requestTemporaryFullAccuracyAuthorization: .init {
          if #available(macOS 11, *) {
            return manager.requestTemporaryFullAccuracyAuthorization(
              withPurposeKey: $0, completion: $1)
          } else {
            fatalError(
              "'requestTemporaryFullAccuracyAuthorization(withPurposeKey:completion:)' is unavailable"
            )
          }
        },
        authorizationStatus: .init {
          if #available(macOS 11, *) {
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
        pausesLocationUpdatesAutomatically: .init(
          .init(
            get: { manager.pausesLocationUpdatesAutomatically },
            set: { manager.pausesLocationUpdatesAutomatically = $0 }
          )),
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
        startMonitoringSignificantLocationChanges: .init {
          manager.startMonitoringSignificantLocationChanges()
        },
        stopMonitoringSignificantLocationChanges: .init {
          manager.stopMonitoringSignificantLocationChanges()
        },
        startMonitoringVisits: .init { manager.startMonitoringVisits() },
        stopMonitoringVisits: .init { manager.stopMonitoringVisits() },
        startUpdatingHeading: .init { manager.startUpdatingHeading() },
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
        startMonitoring: .init { manager.startMonitoring(for: $0) },
        stopMonitoring: .init { manager.stopMonitoring(for: $0) },
        monitoredRegions: .init { manager.monitoredRegions },
        maximumRegionMonitoringDistance: .init { manager.maximumRegionMonitoringDistance },
        requestState: .init { manager.requestState(for: $0) },
        startRangingBeacons: .init { manager.startRangingBeacons(satisfying: $0) },
        stopRangingBeacons: .init { manager.stopRangingBeacons(satisfying: $0) },
        rangedBeaconConstraints: .init { manager.rangedBeaconConstraints },
        location: .init { manager.location },
        heading: .init { manager.heading }
      )
      return LocationManager(_implementation: _implementation)
    }
  }

  extension LocationManager {
    static var unimplemented: LocationManager {
      let _implementation = Implementation(
        significantLocationChangeMonitoringAvailable: .unimplemented(
          #"@Dependency(\.locationManager.significantLocationChangeMonitoringAvailable)"#,
          placeholder: false),
        headingAvailable: .unimplemented(
          #"@Dependency(\.locationManager.headingAvailable)"#,
          placeholder: false),
        isAuthorizedForWidgetUpdates: .unimplemented(
          #"@Dependency(\.locationManager.isAuthorizedForWidgetUpdates)"#,
          placeholder: false),
        accuracyAuthorization: .unimplemented(
          #"@Dependency(\.locationManager.accuracyAuthorization)"#,
          placeholder: .reducedAccuracy),
        isMonitoringAvailable: .unimplemented(
          #"@Dependency(\.locationManager.isMonitoringAvailable)"#),
        isRangingAvailable: .unimplemented(
          #"@Dependency(\.locationManager.isRangingAvailable)"#,
          placeholder: false),
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
        pausesLocationUpdatesAutomatically: .unimplemented(
          #"@Dependency(\.locationManager.pausesLocationUpdatesAutomatically)"#),
        allowsBackgroundLocationUpdates: .unimplemented(
          #"@Dependency(\.locationManager.allowsBackgroundLocationUpdates)"#,
          placeholder: false),
        activityType: .unimplemented(
          #"@Dependency(\.locationManager.activityType)"#),
        startMonitoringSignificantLocationChanges: .unimplemented(
          #"@Dependency(\.locationManager.startMonitoringSignificantLocationChanges)"#),
        stopMonitoringSignificantLocationChanges: .unimplemented(
          #"@Dependency(\.locationManager.stopMonitoringSignificantLocationChanges)"#),
        startMonitoringVisits: .unimplemented(
          #"@Dependency(\.locationManager.startMonitoringVisits)"#),
        stopMonitoringVisits: .unimplemented(
          #"@Dependency(\.locationManager.stopMonitoringVisits)"#),
        startUpdatingHeading: .unimplemented(
          #"@Dependency(\.locationManager.startUpdatingHeading)"#),
        dismissHeadingCalibrationDisplay: .unimplemented(
          #"@Dependency(\.locationManager.dismissHeadingCalibrationDisplay)"#),
        headingFilter: .unimplemented(
          #"@Dependency(\.locationManager.headingFilter)"#),
        headingOrientation: .unimplemented(
          #"@Dependency(\.locationManager.headingOrientation)"#),
        startMonitoring: .unimplemented(
          #"@Dependency(\.locationManager.startMonitoring)"#),
        stopMonitoring: .unimplemented(
          #"@Dependency(\.locationManager.stopMonitoring)"#),
        monitoredRegions: .unimplemented(
          #"@Dependency(\.locationManager.monitoredRegions)"#),
        maximumRegionMonitoringDistance: .unimplemented(
          #"@Dependency(\.locationManager.maximumRegionMonitoringDistance)"#),
        requestState: .unimplemented(
          #"@Dependency(\.locationManager.requestState)"#),
        startRangingBeacons: .unimplemented(
          #"@Dependency(\.locationManager.startRangingBeacons)"#),
        stopRangingBeacons: .unimplemented(
          #"@Dependency(\.locationManager.stopRangingBeacons)"#),
        rangedBeaconConstraints: .unimplemented(
          #"@Dependency(\.locationManager.rangedBeaconConstraints)"#),
        location: .unimplemented(
          #"@Dependency(\.locationManager.location)"#),
        heading: .unimplemented(
          #"@Dependency(\.locationManager.heading)"#)
      )
      return LocationManager(_implementation: _implementation)
    }
  }
#endif

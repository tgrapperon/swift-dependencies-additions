#if canImport(CoreLocation)
  @preconcurrency import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics

  extension DependencyValues {
    /// An abstraction of `CLLocationManager`, the central object for managing
    /// notification-related activities for your app or app extension.
    public var locationManager: LocationManager {
      get { self[LocationManager.self] }
      set { self[LocationManager.self] = newValue }
    }
  }

  extension LocationManager: DependencyKey {
    public static var liveValue: LocationManager { .system }
    public static var testValue: LocationManager { .unimplemented }
    public static var previewValue: LocationManager { .system }
  }

  public struct LocationManager: Sendable, ConfigurableProxy {
    public struct Implementation: Sendable {
      // MARK: Determining the availability of services
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        @ReadOnlyProxy public var significantLocationChangeMonitoringAvailable: Bool
      #endif
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @ReadOnlyProxy public var headingAvailable: Bool
      #endif
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        @ReadOnlyProxy public var isAuthorizedForWidgetUpdates: Bool
      #endif
      @ReadOnlyProxy public var accuracyAuthorization: CLAccuracyAuthorization
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        @FunctionProxy public var isMonitoringAvailable: @Sendable (AnyClass) -> Bool
        @ReadOnlyProxy public var isRangingAvailable: Bool
      #endif
      @ReadOnlyProxy public var locationServicesEnabled: Bool

      // MARK: Receiving data from location services
      @ReadWriteProxy public var delegate: (CLLocationManagerDelegate & Sendable)?

      // MARK: Requesting authorization for location services
      @FunctionProxy public var requestWhenInUseAuthorization: @Sendable () -> Void
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @FunctionProxy public var requestAlwaysAuthorization: @Sendable () -> Void
      #endif
      @FunctionProxy public var requestTemporaryFullAccuracyAuthorization:
        @Sendable (_ purposeKey: String, _ completion: ((Error?) -> Void)?) -> Void
      @ReadOnlyProxy public var authorizationStatus: CLAuthorizationStatus

      // MARK: Specifying distance and accuracy
      @ReadWriteProxy public var distanceFilter: CLLocationDistance
      @ReadWriteProxy public var desiredAccuracy: CLLocationAccuracy

      // MARK: Running the standard location service
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @FunctionProxy public var startUpdatingLocation: @Sendable () -> Void
      #endif
      @FunctionProxy public var stopUpdatingLocation: @Sendable () -> Void
      @FunctionProxy public var requestLocation: @Sendable () -> Void
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        @ReadWriteProxy public var pausesLocationUpdatesAutomatically: Bool
      #endif
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @ReadWriteProxy public var allowsBackgroundLocationUpdates: Bool
      #endif
      #if os(iOS) || targetEnvironment(macCatalyst)
        @ReadWriteProxy public var showsBackgroundLocationIndicator: Bool
      #endif
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @ReadWriteProxy public var activityType: CLActivityType
      #endif

      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        // MARK: Running the significant change location service
        @FunctionProxy public var startMonitoringSignificantLocationChanges: @Sendable () -> Void
        @FunctionProxy public var stopMonitoringSignificantLocationChanges: @Sendable () -> Void

        // MARK: Running the visits location service
        @FunctionProxy public var startMonitoringVisits: @Sendable () -> Void
        @FunctionProxy public var stopMonitoringVisits: @Sendable () -> Void
      #endif

      // MARK: Running the heading service
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @FunctionProxy public var startUpdatingHeading: @Sendable () -> Void
      #endif
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @FunctionProxy public var stopUpdatingHeading: @Sendable () -> Void
      #endif
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @FunctionProxy public var dismissHeadingCalibrationDisplay: @Sendable () -> Void
        @ReadWriteProxy public var headingFilter: CLLocationDegrees
        @ReadWriteProxy public var headingOrientation: CLDeviceOrientation
      #endif

      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        // MARK: Running the region-monitoring service
        @FunctionProxy public var startMonitoring: @Sendable (CLRegion) -> Void
        @FunctionProxy public var stopMonitoring: @Sendable (CLRegion) -> Void
        @ReadOnlyProxy public var monitoredRegions: Set<CLRegion>
        @ReadOnlyProxy public var maximumRegionMonitoringDistance: CLLocationDistance

        // MARK: Performing beacon ranging
        @FunctionProxy public var requestState: @Sendable (CLRegion) -> Void
        @FunctionProxy public var startRangingBeacons:
          @Sendable (CLBeaconIdentityConstraint) -> Void
        @FunctionProxy public var stopRangingBeacons: @Sendable (CLBeaconIdentityConstraint) -> Void
        @ReadOnlyProxy public var rangedBeaconConstraints: Set<CLBeaconIdentityConstraint>
      #endif

      #if os(iOS)
        // MARK: Monitoring location push notifications
        @FunctionProxy public var startMonitoringLocationPushes:
          @Sendable (_ completion: ((Data?, Error?) -> Void)?) -> Void
        @FunctionProxy public var stopMonitoringLocationPushes: @Sendable () -> Void
      #endif

      // MARK: Getting recent location and heading data
      @ReadOnlyProxy public var location: CLLocation?
      #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)
        @ReadOnlyProxy public var heading: CLHeading?
      #endif

      #if os(watchOS)
        // MARK: watchOS-specific methods
        @FunctionProxy public var requestHistoricalLocations:
          @Sendable (
            _ purposeKey: String,
            _ sampleCount: Int,
            _ completionHandler: @escaping ([CLLocation], Error?) -> Void
          ) -> Void
      #endif
    }

    @_spi(Internals) public var _implementation: Implementation

    // MARK: Determining the availability of services

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      /// Returns a Boolean value indicating whether the significant-change location service is
      /// available on the device.
      @available(iOS 4, macOS 10.7, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func significantLocationChangeMonitoringAvailable() -> Bool {
        self._implementation.significantLocationChangeMonitoringAvailable
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Returns a Boolean value indicating whether the location manager is able to generate
      /// heading-related events.
      @available(iOS 4, macOS 10.7, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public func headingAvailable() -> Bool {
        self._implementation.headingAvailable
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      /// A Boolean value that indicates whether a widget is eligible to receive location updates.
      @available(iOS 14, macOS 11, macCatalyst 14, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var isAuthorizedForWidgetUpdates: Bool {
        self._implementation.isAuthorizedForWidgetUpdates
      }

    #endif

    /// A value that indicates the level of location accuracy the app has permission to use.
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, watchOS 7, *)
    public var accuracyAuthorization: CLAccuracyAuthorization {
      self._implementation.accuracyAuthorization
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      /// Returns a Boolean value indicating whether the device supports region monitoring using the
      /// specified class.
      @available(iOS 7, macOS 10.10, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func isMonitoringAvailable(for class: AnyClass) -> Bool {
        self._implementation.isMonitoringAvailable(`class`)
      }

      /// Returns a Boolean value indicating whether the device supports ranging of beacons that use
      /// the iBeacon protocol.
      @available(iOS 7, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func isRangingAvailable() -> Bool {
        self._implementation.isRangingAvailable
      }

    #endif

    /// Returns a Boolean value indicating whether location services are enabled on the device.
    @available(iOS 4, macOS 10.7, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public func locationServicesEnabled() -> Bool {
      self._implementation.locationServicesEnabled
    }

    // MARK: Receiving data from location services

    /// The delegate object to receive update events.
    @available(iOS 2, macOS 10.6, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public var delegate: (CLLocationManagerDelegate & Sendable)? {
      get { self._implementation.delegate }
      nonmutating set { self._implementation.delegate = newValue }
    }

    // MARK: Requesting authorization for location services

    /// Requests the user’s permission to use location services while the app is in use.
    @available(iOS 8, macOS 10.15, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public func requestWhenInUseAuthorization() {
      self._implementation.requestWhenInUseAuthorization()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Requests the user’s permission to use location services regardless of whether the app is
      /// in use.
      @available(iOS 8, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public func requestAlwaysAuthorization() {
        self._implementation.requestAlwaysAuthorization()
      }

    #endif

    /// Requests permission to temporarily use location services with full accuracy and reports the
    /// results to the provided completion handler.
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, watchOS 7, *)
    public func requestTemporaryFullAccuracyAuthorization(
      withPurposeKey purposeKey: String,
      completion: ((Error?) -> Void)?
    ) {
      self._implementation.requestTemporaryFullAccuracyAuthorization(purposeKey, completion)
    }

    /// Requests permission to temporarily use location services with full accuracy.
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, watchOS 7, *)
    public func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
      self._implementation.requestTemporaryFullAccuracyAuthorization(purposeKey, nil)
    }

    /// The current authorization status for the app.
    @available(iOS 14, macOS 11, macCatalyst 14, tvOS 14, watchOS 7, *)
    public var authorizationStatus: CLAuthorizationStatus {
      self._implementation.authorizationStatus
    }

    // MARK: Specifying distance and accuracy

    /// The minimum distance in meters the device must move horizontally before an update event
    /// is generated.
    @available(iOS 2, macOS 10.6, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public var distanceFilter: CLLocationDistance {
      get { self._implementation.distanceFilter }
      nonmutating set { self._implementation.distanceFilter = newValue }
    }

    /// The accuracy of the location data that your app wants to receive.
    @available(iOS 2, macOS 10.6, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public var desiredAccuracy: CLLocationAccuracy {
      get { self._implementation.desiredAccuracy }
      nonmutating set { self._implementation.desiredAccuracy = newValue }
    }

    // MARK: Running the standard location service

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Starts the generation of updates that report the user’s current location.
      @available(iOS 2, macOS 10.6, macCatalyst 13, watchOS 3, *)
      @available(tvOS, unavailable)
      public func startUpdatingLocation() {
        self._implementation.startUpdatingLocation()
      }

    #endif

    /// Stops the generation of location updates.
    @available(iOS 2, macOS 10.6, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public func stopUpdatingLocation() {
      self._implementation.stopUpdatingLocation()
    }

    /// Requests the one-time delivery of the user’s current location.
    @available(iOS 9, macOS 10.14, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public func requestLocation() {
      self._implementation.requestLocation()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      /// A Boolean value that indicates whether the location-manager object may pause location updates.
      @available(iOS 6, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var pausesLocationUpdatesAutomatically: Bool {
        get { self._implementation.pausesLocationUpdatesAutomatically }
        nonmutating set { self._implementation.pausesLocationUpdatesAutomatically = newValue }
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// A Boolean value that indicates whether the app receives location updates when running
      /// in the background.
      @available(iOS 6, macOS 10.15, macCatalyst 13.1, watchOS 4, *)
      @available(tvOS, unavailable)
      public var allowsBackgroundLocationUpdates: Bool {
        get { self._implementation.allowsBackgroundLocationUpdates }
        nonmutating set { self._implementation.allowsBackgroundLocationUpdates = newValue }
      }

    #endif

    #if os(iOS) || targetEnvironment(macCatalyst)

      /// A Boolean value that indicates whether the status bar changes its appearance when an app uses
      /// location services in the background.
      @available(iOS 11, macCatalyst 13.1, *)
      @available(macOS, unavailable)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var showsBackgroundLocationIndicator: Bool {
        get { self._implementation.showsBackgroundLocationIndicator }
        nonmutating set { self._implementation.showsBackgroundLocationIndicator = newValue }
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// The type of activity the app expects the user to typically perform while in the app’s
      /// location session.
      @available(iOS 6, macOS 10.15, macCatalyst 13.1, watchOS 4, *)
      @available(tvOS, unavailable)
      public var activityType: CLActivityType {
        get { self._implementation.activityType }
        nonmutating set { self._implementation.activityType = newValue }
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      // MARK: Running the significant change location service

      /// Starts the generation of updates based on significant location changes.
      @available(iOS 4, macOS 10.7, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func startMonitoringSignificantLocationChanges() {
        self._implementation.startMonitoringSignificantLocationChanges()
      }

      /// Stops the delivery of location events based on significant location changes.
      @available(iOS 4, macOS 10.7, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func stopMonitoringSignificantLocationChanges() {
        self._implementation.stopMonitoringSignificantLocationChanges()
      }

      // MARK: Running the visits location service

      /// Starts the delivery of visit-related events.
      @available(iOS 8, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func startMonitoringVisits() {
        self._implementation.startMonitoringVisits()
      }

      /// Stops the delivery of visit-related events.
      @available(iOS 8, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func stopMonitoringVisits() {
        self._implementation.stopMonitoringVisits()
      }

    #endif

    // MARK: Running the heading service

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Starts the generation of updates that report the user’s current heading.
      @available(iOS 3, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public func startUpdatingHeading() {
        self._implementation.startUpdatingHeading()
      }

    #endif

    #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Stops the generation of heading updates.
      @available(iOS 3, macCatalyst 13.1, watchOS 2, *)
      @available(macOS, unavailable)
      @available(tvOS, unavailable)
      public func stopUpdatingHeading() {
        self._implementation.stopUpdatingHeading()
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// Dismisses the heading calibration view from the screen immediately.
      @available(iOS 3, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public func dismissHeadingCalibrationDisplay() {
        self._implementation.dismissHeadingCalibrationDisplay()
      }

      /// The minimum angular change in degrees required to generate new heading events.
      @available(iOS 3, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public var headingFilter: CLLocationDegrees {
        get { self._implementation.headingFilter }
        nonmutating set { self._implementation.headingFilter = newValue }
      }

      /// The device orientation to use when computing heading values.
      @available(iOS 4, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public var headingOrientation: CLDeviceOrientation {
        get { self._implementation.headingOrientation }
        nonmutating set { self._implementation.headingOrientation = newValue }
      }

    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

      // MARK: Running the region-monitoring service

      /// Starts monitoring the specified region.
      @available(iOS 5, macOS 10.8, macCatalyst 13.1, *)
      @available(watchOS, unavailable)
      @available(tvOS, unavailable)
      public func startMonitoring(for region: CLRegion) {
        self._implementation.startMonitoring(region)
      }

      /// Stops monitoring the specified region.
      @available(iOS 4, macOS 10.8, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func stopMonitoring(for region: CLRegion) {
        self._implementation.stopMonitoring(region)
      }

      /// The set of shared regions monitored by all location-manager objects.
      @available(iOS 4, macOS 10.8, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var monitoredRegions: Set<CLRegion> {
        self._implementation.monitoredRegions
      }

      /// The largest boundary distance that can be assigned to a region.
      @available(iOS 4, macOS 10.8, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var maximumRegionMonitoringDistance: CLLocationDistance {
        self._implementation.maximumRegionMonitoringDistance
      }

      // MARK: Performing beacon ranging

      /// Retrieves the state of a region asynchronously.
      @available(iOS 7, macOS 10.10, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func requestState(for region: CLRegion) {
        self._implementation.requestState(region)
      }

      /// Starts the delivery of notifications for the specified beacon constraints.
      @available(iOS 13, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func startRangingBeacons(satisfying constraint: CLBeaconIdentityConstraint) {
        self._implementation.startRangingBeacons(constraint)
      }

      /// Stops the delivery of notifications for the specified beacon constraints.
      @available(iOS 13, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func stopRangingBeacons(satisfying constraint: CLBeaconIdentityConstraint) {
        self._implementation.stopRangingBeacons(constraint)
      }

      /// The set of beacon constraints currently being tracked using ranging.
      @available(iOS 13, macOS 10.15, macCatalyst 13.1, *)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public var rangedBeaconConstraints: Set<CLBeaconIdentityConstraint> {
        self._implementation.rangedBeaconConstraints
      }

    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)

      // MARK: Monitoring location push notifications

      /// Starts monitoring for the delivery of Apple Push Notification service (APNs) location pushes,
      /// and provides a device-specific token for sending pushes.
      @available(iOS 15, *)
      @available(macOS, unavailable)
      @available(macCatalyst, unavailable)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func startMonitoringLocationPushes(completion: ((Data?, Error?) -> Void)?) {
        self._implementation.startMonitoringLocationPushes(completion)
      }

      /// Stops monitoring for Apple Push Notification service (APNs) location pushes.
      @available(iOS 15, *)
      @available(macOS, unavailable)
      @available(macCatalyst, unavailable)
      @available(tvOS, unavailable)
      @available(watchOS, unavailable)
      public func stopMonitoringLocationPushes() {
        self._implementation.stopMonitoringLocationPushes()
      }

    #endif

    // MARK: Getting recent location and heading data

    /// The most recently retrieved user location.
    @available(iOS 2, macOS 10.6, macCatalyst 13.1, tvOS 9, watchOS 2, *)
    public var location: CLLocation? {
      self._implementation.location
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(watchOS)

      /// The most recently reported heading.
      @available(iOS 4, macOS 10.15, macCatalyst 13.1, watchOS 2, *)
      @available(tvOS, unavailable)
      public var heading: CLHeading? {
        self._implementation.heading
      }

    #endif

    #if os(watchOS)

      // MARK: watchOS-specific methods

      @available(watchOS 9, *)
      @available(iOS, unavailable)
      @available(macOS, unavailable)
      @available(macCatalyst, unavailable)
      @available(tvOS, unavailable)
      public func requestHistoricalLocations(
        purposeKey: String,
        sampleCount: Int,
        completionHandler: @escaping ([CLLocation], Error?) -> Void
      ) {
        self._implementation.requestHistoricalLocations(purposeKey, sampleCount, completionHandler)
      }

    #endif
  }
#endif

#if canImport(CoreLocation)
  import CoreLocation
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import LocationManagerDependency
  import XCTest
  import _LocationDependency

  final class LocationDependencyTests: XCTestCase {
    func testGetLocation() async throws {
      try await withDependencies {
        let coordinate = IncrementingCoordinateGenerator()

        $0.locationClient.$getLocation = { @Sendable in coordinate() }
      } operation: {
        @Dependency(\.locationClient) var locationClient

        var location = try await locationClient.getLocation()
        XCTAssertEqual(location.latitude, 0)

        location = try await locationClient.getLocation()
        XCTAssertEqual(location.latitude, 1)
      }
    }

    func testDesiredAccuracy() async throws {
      // This is the desired behavior
      let manager1 = CLLocationManager()
      let manager2 = CLLocationManager()
      manager1.desiredAccuracy = 1
      manager2.desiredAccuracy = 2
      XCTAssertEqual(manager1.desiredAccuracy, 1)
      XCTAssertEqual(manager2.desiredAccuracy, 2)

      final class Model {
        @Dependency(\.locationManager) var locationManager
        @Dependency(\.locationClient) var locationClient
      }

      let (model1, model2) = withDependencies {
        let coordinate = IncrementingCoordinateGenerator()
        $0.locationClient.$getLocation = { @Sendable in
          @Dependency(\.locationManager) var locationManager
          let coordinate = coordinate()
          if locationManager.desiredAccuracy == kCLLocationAccuracyReduced {
            return CLLocationCoordinate2D(
              latitude: coordinate.latitude * 100,
              longitude: coordinate.longitude * 100
            )
          } else {
            return coordinate
          }
        }
      } operation: {
        let model1 = Model()
        let model2 = withDependencies {
          // The second model has a different `locationManager` instance,
          // so it can set a custom desired accuracy.
          $0.locationManager = .testValue
        } operation: {
          Model()
        }
        return (model1, model2)
      }

      // Both models need different accuracies
      model1.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      model2.locationManager.desiredAccuracy = kCLLocationAccuracyReduced
      XCTAssertEqual(model1.locationManager.desiredAccuracy, kCLLocationAccuracyBest)
      XCTAssertEqual(model2.locationManager.desiredAccuracy, kCLLocationAccuracyReduced)

      // Getting the location from the first model gives accurate coordinates
      try await withDependencies(from: model1) {
        $0.locationManager.$desiredAccuracy = .constant(kCLLocationAccuracyBest)
      } operation: {
        var location = try await model1.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 0)

        location = try await model1.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 1)
      }

      // Getting the location from the second model gives inaccurate coordinates
      try await withDependencies(from: model2) {
        $0.locationManager.$desiredAccuracy = .constant(kCLLocationAccuracyReduced)
      } operation: {
        var location = try await model2.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 200)

        location = try await model2.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 300)
      }

      // Changing the accuracy on one model changes the accuracy of the results
      do {
        XCTAssertEqual(model1.locationManager.desiredAccuracy, kCLLocationAccuracyBest)
        var location = try await model1.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 4)

        model1.locationManager.desiredAccuracy = kCLLocationAccuracyReduced

        location = try await model1.locationClient.getLocation()
        XCTAssertEqual(location.latitude, 500)
      }
    }
  }

  private final class IncrementingCoordinateGenerator: @unchecked Sendable {
    private let lock = NSLock()
    private var sequence: CLLocationDegrees = 0

    func callAsFunction() -> CLLocationCoordinate2D {
      self.lock.lock()
      defer {
        self.sequence += 1
        self.lock.unlock()
      }
      return CLLocationCoordinate2D(latitude: self.sequence, longitude: self.sequence)
    }
  }
#endif

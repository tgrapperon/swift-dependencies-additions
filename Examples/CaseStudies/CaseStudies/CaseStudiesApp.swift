import DependenciesAdditions
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct Case_StudiesApp: App {
  var body: some Scene {
    WindowGroup {
      StudiesView(
        model: withDependencies {
          $0.persistentContainer = .default(inMemory: true).withInitialData()
          #if targetEnvironment(simulator)
          // Note: This will emit warnings, as using these `$` accessors should only
          // be used for previews and testing, but we do so here because the following
          // values are undefined when running on the simulator.
          // We are furthermore forced to perform a `context` danse to avoid emitting
          // runtime warning, as one shouldn't access `$` device properties
          // in a `live` context. So we temporarily switch to a `preview` context
          // to avoid the warning when we access the values two lines below.
          var dependencies = $0
          withDependencies { inner in
            inner.context = .preview
          } operation: {
            dependencies.device.$batteryLevel = 0.72
            dependencies.device.$batteryState = UIDevice.BatteryState.charging
          }
          $0 = dependencies
          $0.device.$isBatteryMonitoringEnabled = .constant(true)
          $0.context = .live
          #endif
        } operation: {
          .init()
        }
      )
    }
  }
}

import Dependencies
import SwiftUI

@main
struct Case_StudiesApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        model: DependencyValues.withValues {
          $0.persistentContainer = .canonical(inMemory: true).withInitialData()
        } operation: {
          .init()
        }
      )
    }
  }
}

import Dependencies
import SwiftUI

@main
struct Case_StudiesApp: App {
  var body: some Scene {
    WindowGroup {
//      StudiesView(
//        model: DependencyValues.withValues {
//          $0.persistentContainer = .canonical(inMemory: true).withInitialData()
//        } operation: {
//          .init()
//        }
//      )
      NotificationsStudyView_Previews.previews
    }
  }
}

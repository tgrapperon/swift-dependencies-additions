import AppStorageDependency
import Combine
import Dependencies
import SwiftUI

@MainActor
final class UserDefaultsStudy: ObservableObject {
  // This preference has a default value
  @Dependency.AppStorage("number") var number: Int = 42
  // This preference has a `nil` default value
  @Dependency.AppStorage("string") var string: String?

  @Published var publishedNumber: Int = 0
  @Published var publishedString: String?

  @Published var observedNumberValue: Int?
  @Published var observedStringValue: String?

  private var cancellables = Set<AnyCancellable>()
  private var tasks = Set<Task<Void, Never>>()

  init() {
    // Load the stored values
    self.publishedNumber = self.number
    self.publishedString = self.string

    // Automatically save the updated values
    self.$publishedNumber
      .dropFirst()
      .compactMap { $0 }
      .removeDuplicates()
      .sink { [weak self] in
        self?.number = $0
      }
      .store(in: &self.cancellables)

    self.$publishedString
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] in
        self?.string = $0
      }
      .store(in: &self.cancellables)

    self.tasks.insert(
      Task { [weak self] in
        guard let self else { return }
        for await newValue in self.$number.values() {
          self.observedNumberValue = newValue
        }
      }
    )

    self.tasks.insert(
      Task { [weak self] in
        guard let self else { return }
        for await newValue in self.$string.values() {
          self.observedStringValue = newValue
        }
      }
    )
  }

  deinit {
    for task in self.tasks {
      task.cancel()
    }
  }

  func userDidTapResetNumber() {
    self.$number.reset()
    self.publishedNumber = self.number
  }

  func userDidTapResetString() {
    self.$string.reset()
    self.publishedString = self.string
  }

  func userDidUpdateNumber(value: Int) {
    self.publishedNumber = value
  }

  func userDidUpdateString(value: String) {
    self.publishedString = value
  }
}

struct UserDefaultsStudyView: View {
  @ObservedObject var model: UserDefaultsStudy
  @AppStorage("number") var numberFromSwiftUI: Int = 42
  @AppStorage("string") var stringFromSwiftUI: String?
  
  var body: some View {
    List {
      numberView
      stringView
    }
    .headerProminence(.increased)
    .navigationTitle("App Storage")
  }
  
  var numberView: some View {
    Section {
      LabeledContent(
        "Model value, seeded from UserDefaults",
        value: model.publishedNumber.formatted()
      )
      LabeledContent(
        "Auto-updating from UserDefaults",
        value: String(describing: model.observedNumberValue)
      )
      LabeledContent(
        "AppStorage from SwiftUI",
        value: numberFromSwiftUI.formatted()
      )
      
      Stepper {
        Text("Change number")
      } onIncrement: {
        model.userDidUpdateNumber(value: model.publishedNumber + 1)
      } onDecrement: {
        model.userDidUpdateNumber(value: model.publishedNumber - 1)
      }
    
      Button(role: .destructive) {
        model.userDidTapResetNumber()
      } label: {
        Text("Reset")
      }
    } header: {
      Text("Number")
    }
  }
  
  var stringView: some View {
    Section {
      LabeledContent(
        "Model value, seeded from UserDefaults",
        value: model.publishedString ?? "nil"
      )
      LabeledContent(
        "Auto-updating from UserDefaults",
        value: String(describing: model.observedStringValue)
      )
      LabeledContent(
        "AppStorage from SwiftUI",
        value: String(describing: stringFromSwiftUI)
      )

      TextField("String", text: Binding  {
        self.model.publishedString ?? ""
      } set: { newvalue in
        self.model.publishedString = newvalue.isEmpty ? nil : newvalue
      })
      .textFieldStyle(.roundedBorder)
      
      Button(role: .destructive) {
        model.userDidTapResetString()
      } label: {
        Text("Reset")
      }
    } header: {
      Text("String")
    }
  }
}

struct UserDefaultsStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      UserDefaultsStudyView(
        // By default, `\.userDefaults` is `.ephemeral()` for SwiftUI Previews
        // but we force the `.standard` one, so they reflect the same values
        // as SwiftUI's `AppStorage`, which is not configurable.
        model: DependencyValues.withValue(\.userDefaults, .standard) {
          .init()
        }
      )
    }
  }
}

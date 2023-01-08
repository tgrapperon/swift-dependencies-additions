import _AppStorageDependency
import Combine
import SwiftUI

@MainActor
final class UserDefaultsStudy: ObservableObject {
  // This preference has a default value
  @Dependency.AppStorage("number") var number: Int = 42
  // This preference has a `nil` default value
  @Dependency.AppStorage("string") var string: String?

  @Dependency(\.mainQueue) var mainQueue

  @Published var publishedNumber: Int = 0
  @Published var publishedString: String?

  @Published var observedNumberValue: Int?
  @Published var observedStringValue: String?

  private var cancellables = Set<AnyCancellable>()

  init() {
    self.$number.assign(to: &self.$publishedNumber)
    self.$string.assign(to: &self.$publishedString)

    // Automatically save the updated number.
    self.$publishedNumber
      .dropFirst()
      .removeDuplicates() // We don't want infinite loops
      .debounce(for: .milliseconds(250), scheduler: self.mainQueue)
      .compactMap { $0 }
      .sink { [weak self] in
        self?.number = $0
      }
      .store(in: &self.cancellables)

    // Automatically save the updated string.
    self.$publishedString
      .dropFirst()
      .removeDuplicates() // We don't want infinite loops
      .debounce(for: .milliseconds(250), scheduler: self.mainQueue)
      .sink { [weak self] in
        self?.string = $0
      }
      .store(in: &self.cancellables)

    // Observe the user defaults, and publish the number changes
    // to `observedNumberValue`.
    Task { [weak self] in
      guard let self else { return }
      for await newValue in self.$number {
        self.observedNumberValue = newValue
      }
    }.store(in: &self.cancellables)

    // Observe the user defaults, and publish the string changes
    // to `observedStringValue`.
    Task { [weak self] in
      guard let self else { return }
      for await newValue in self.$string {
        self.observedStringValue = newValue
      }
    }.store(in: &self.cancellables)
  }

  func resetNumberButtonTapped() {
    self.$number.reset()
    self.publishedNumber = self.number
  }

  func resetStringButtonTapped() {
    self.$string.reset()
    self.publishedString = self.string
  }

  func updateNumberButtonTapped(value: Int) {
    self.publishedNumber = value
  }
}

struct UserDefaultsStudyView: View {
  @ObservedObject var model: UserDefaultsStudy
  // We define these SwiftUI values to show that they expose the same
  // values as the model because the keys are the same.
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
        "Model value, seeded from and following UserDefaults",
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
        model.updateNumberButtonTapped(value: model.publishedNumber + 1)
      } onDecrement: {
        model.updateNumberButtonTapped(value: model.publishedNumber - 1)
      }

      Button(role: .destructive) {
        model.resetNumberButtonTapped()
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
        "Model value, seeded from and following UserDefaults",
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

      TextField("String", text: Binding {
        self.model.publishedString ?? ""
      } set: { newvalue in
        self.model.publishedString = newvalue.isEmpty ? nil : newvalue
      })
      .textFieldStyle(.roundedBorder)

      Button(role: .destructive) {
        model.resetStringButtonTapped()
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
        // as SwiftUI's `AppStorage`, which doesn't support in memory storage
        model: withDependencies {
          $0.userDefaults = .standard
        } operation: {
          .init()
        }
      )
    }
  }
}

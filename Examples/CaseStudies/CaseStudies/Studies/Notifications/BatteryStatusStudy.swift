import Dependencies
import NotificationCenterDependency
import SwiftUI
import SwiftUINavigation
import _NotificationDependency

#if os(iOS)
  @MainActor
  final class BatteryStatusStudy: ObservableObject {
    @Published var batteryLevel: Float = 0
    @Published var batteryState: UIDevice.BatteryState = .unknown

    @Dependency.Notification(\.batteryLevelDidChange) var batteryLevelNotification
    @Dependency.Notification(\.batteryStateDidChange) var batteryStateNotification
    /// Required to enable/disable notifications in `onAppear`/`onDisappear`.
    @Dependency(\.device) var device

    init() {
      // Inject the notifications into the `@Published` properties:
      self.batteryLevelNotification.assign(to: &self.$batteryLevel)
      self.batteryStateNotification.assign(to: &self.$batteryState)
    }

    func onAppear() {
      self.device.isBatteryMonitoringEnabled = true
    }

    func onDisappear() {
      self.device.isBatteryMonitoringEnabled = false
    }
  }

  struct BatteryStatusStudyView: View {
    /// We use a `StateObject.Dependency` which is a special `StateObject` that
    /// can capture dependencies when `withDependencies` wraps a whole view instead
    /// of only the model's init, like its the case for the preview below.
    @StateObject.Dependency var model: BatteryStatusStudy

    var body: some View {
      List {
        Section {
          LabeledContent("Battery Level") {
            HStack {
              Text(batteryStateLocalizedText)
              Text(
                model.batteryLevel.formatted(
                  .percent.precision(.fractionLength(0)))
              )
              .monospacedDigit()
              Group {
                if model.batteryLevel > 0.875 {
                  if model.batteryState == .full {
                    Image(systemName: "battery.100.bolt")
                  } else {
                    Image(systemName: "battery.100")
                  }
                } else if model.batteryLevel > 0.625 {
                  Image(systemName: "battery.75")
                } else if model.batteryLevel > 0.375 {
                  Image(systemName: "battery.50")
                } else if model.batteryLevel > 0.125 {
                  Image(systemName: "battery.25")
                } else {
                  Image(systemName: "battery.0")
                }
              }
              .symbolRenderingMode(.multicolor)
              .imageScale(.large)
            }
          }
        } header: {
          Text(#"\\.batteryLevelDidChange"#)
            .textCase(.none)
            .monospaced()
        }
      }
      .onAppear {
        model.onAppear()
      }
      .onDisappear {
        model.onDisappear()
      }
      .navigationTitle("Battery Status")
    }

    var batteryStateLocalizedText: String {
      switch self.model.batteryState {
      case .unknown:
        return "Unknown"
      case .unplugged:
        return "Unplugged"
      case .charging:
        return "Charging"
      case .full:
        return "Full"
      @unknown default:
        return "Unknown"
      }
    }
  }

  struct BatteryStatusStudyView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationStack {
        WithState(initialValue: Float(0.72)) { $batteryLevel in
          WithState(initialValue: UIDevice.BatteryState.unplugged) { $batteryState in
            withDependencies {
              $0.device.$isBatteryMonitoringEnabled = .constant(true)
              $0.device.$batteryState = { @Sendable in batteryState }
              $0.device.$batteryLevel = { @Sendable in batteryLevel }
            } operation: {
              BatteryStatusStudyView(model: .init())
                .onChange(of: batteryLevel) { _ in
                  @Dependency(\.notificationCenter) var notificationCenter
                  notificationCenter.post(name: UIDevice.batteryLevelDidChangeNotification)
                }
                .onChange(of: batteryState) { _ in
                  @Dependency(\.notificationCenter) var notificationCenter
                  notificationCenter.post(name: UIDevice.batteryStateDidChangeNotification)
                }
                .safeAreaInset(edge: .bottom) {
                  VStack(spacing: 4) {
                    Text("Preview control (not part of the View)")
                      .bold()
                      .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                      Slider(value: $batteryLevel, in: 0...1)
                      Text(
                        "Battery Level: \(batteryLevel.formatted(.percent.precision(.fractionLength(0))))"
                      )
                    }

                    Picker(selection: $batteryState) {
                      Text("Unknown").tag(UIDevice.BatteryState.unknown)
                      Text("Unplugged").tag(UIDevice.BatteryState.unplugged)
                      Text("Charging").tag(UIDevice.BatteryState.charging)
                      Text("Full").tag(UIDevice.BatteryState.full)
                    } label: {
                      Text("Battery State")
                    }
                    .pickerStyle(.segmented)
                  }
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                  .padding(8)
                  .background(
                    .ultraThinMaterial
                      .shadow(
                        .drop(
                          color: .black.opacity(0.2),
                          radius: 4
                        )
                      ), in: ContainerRelativeShape()
                  )
                  .padding(.horizontal)
                  .containerShape(RoundedRectangle(cornerRadius: 15))
                }
            }
          }
        }
      }
    }
  }
#endif

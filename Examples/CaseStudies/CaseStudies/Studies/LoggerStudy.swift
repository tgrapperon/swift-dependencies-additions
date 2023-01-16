import DependenciesAdditions
import OSLog
import SwiftUI

final class LoggerStudy: ObservableObject {
  enum Instrument: String {
    case guitar
    case piano
  }

  enum PurchaseError: Error {
    case badLuck
  }

  let customerName: String

  @Dependency(\.logger) var logger
  @Dependency(\.logger["Transactions"]) var transactionsLogger

  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

  init(customerName: String = "Blob") {
    self.customerName = customerName
  }

  func purchaseInstrumentButtonTapped(instrument: Instrument) {
    logger.info("A customer did purchase a \(instrument.rawValue, privacy: .public)")
    Task { [customerName = self.customerName] in
      do {
        try await purchase(instrument: instrument)
        transactionsLogger.info(
          "\(customerName, privacy: .private) did succesfully purchase a \(instrument.rawValue, privacy: .public)"
        )
      } catch {
        transactionsLogger.error(
          "\(customerName, privacy: .private) failed to purchase a \(instrument.rawValue, privacy: .public)"
        )
      }
    }
  }
  /// Purchases fail 30% of the time.
  func purchase(instrument: Instrument) async throws {
    try await Task.sleep(for: .milliseconds(250))
    let randomNumber = withRandomNumberGenerator {
      Int.random(in: 0...2, using: &$0)
    }
    if randomNumber == 1 {
      throw PurchaseError.badLuck
    }
  }
}

struct LoggerStudyView: View {
  @ObservedObject var model: LoggerStudy
  @StateObject.Dependency var loggerModel = LoggerModel()
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        HStack {
          Button {
            model.purchaseInstrumentButtonTapped(instrument: .guitar)
          } label: {
            Label("Buy a guitar", systemImage: "guitars")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 9)
          }
          Button {
            model.purchaseInstrumentButtonTapped(instrument: .piano)
          } label: {
            Label("Buy a piano", systemImage: "pianokeys")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 9)
          }
        }
        .buttonStyle(.borderedProminent)
        Text("Check the console while you tap the buttons above…")
        Text(
          "On a real device that is not connected to a debugger, the private fields of log entries will be redacted."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
      .padding()
      ConsoleView(loggerModel: loggerModel)
    }
    .navigationTitle("Logger")
  }
}
struct ConsoleView: View {
  @ObservedObject var loggerModel: LoggerModel
  var body: some View {
    List {
      ForEach(loggerModel.messages.reversed(), id: \.self) { message in
        VStack(alignment: .leading) {
          HStack(alignment: .firstTextBaseline) {
            Text(message.date.formatted(.dateTime.day().month().year().hour().minute().second()))
            Spacer()
            Text(message.level.localizedDescription)
          }
          .font(.callout)
          if !message.subsystem.isEmpty {
            Text("\(message.subsystem)")
              .font(.headline)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          if !message.category.isEmpty {
            Text("\(message.category)")
              .font(.subheadline)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          Text(message.composedMessage)
            .lineLimit(2)
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(message.level.color)
        .scaleEffect(x: 1, y: -1)
      }
      .listRowInsets(.init(top: 4, leading: 4, bottom: 4, trailing: 2))
    }
    .overlay {
      if self.loggerModel.isLoading {
        ProgressView()
          .progressViewStyle(.automatic)
      }
    }
    .scaleEffect(x: 1, y: -1)
    .listStyle(.plain)
  }
}

@MainActor
final class LoggerModel: ObservableObject {
  @Published var messages: [OSLogEntryLog] = []
  @Published var isLoading: Bool = false
  @Dependency(\.continuousClock) var clock
  @Dependency(\.bundleInfo.bundleIdentifier) var bundleIdentifier
  var cancellables: Set<AnyCancellableTask> = []

  init() {
    Task.detached { [weak self] in
      guard let self else { return }
      do {
        await self.setIsLoading(true)
        try await self.retrieveNewEntries(
          current: self.messages,
          subsystem: self.bundleIdentifier
        )
        await self.setIsLoading(false)
        for await _ in await self.clock.timer(interval: .seconds(1)) {
          try await self.retrieveNewEntries(
            current: self.messages,
            subsystem: self.bundleIdentifier
          )
        }
      } catch {
        print(error)
      }
    }.store(in: &cancellables)
  }

  func setIsLoading(_ isLoading: Bool) {
    self.isLoading = isLoading
  }
  func updateMessages(_ messages: [OSLogEntryLog]) {
    self.messages = messages
  }

  nonisolated
    func retrieveNewEntries(
      current: [OSLogEntryLog],
      subsystem: String
    ) async throws
  {
    let store = try OSLogStore(scope: .currentProcessIdentifier)
    let date = await MainActor.run { current.last?.date }
    let newEntries = try store.getEntries(
      with: [],
      at: store.position(date: .now.addingTimeInterval(-1.5)),
      matching: nil  // Can't make it work on `subsystem` for some reason…
    )
    .lazy
    .compactMap { $0 as? OSLogEntryLog }
    .filter { $0.date > (date ?? .distantPast) }
    .filter { $0.subsystem.isEmpty || $0.subsystem == subsystem }
    await self.updateMessages(current + newEntries)
  }
}

extension OSLogEntryLog.Level {
  var localizedDescription: String {
    switch self {
    case .undefined:
      return "Undefined"
    case .debug:
      return "Debug"
    case .info:
      return "Info"
    case .notice:
      return "Notice"
    case .error:
      return "Error"
    case .fault:
      return "Fault"
    @unknown default:
      return "?"
    }
  }

  var color: Color {
    switch self {
    case .undefined:
      return .primary
    case .debug:
      return .purple
    case .info:
      return .blue
    case .notice:
      return .indigo
    case .error:
      return .red
    case .fault:
      return .pink
    @unknown default:
      return .primary
    }
  }
}

struct LoggerStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoggerStudyView(model: .init())
    }
  }
}

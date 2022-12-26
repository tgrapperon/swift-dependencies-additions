import Dependencies
import LoggerDependency
import SwiftUI

final class LoggerStudy: ObservableObject {
  enum Instrument: String {
    case guitar
    case piano
  }
  enum PurchaseError: Error {
    case badLuck(UInt64)
  }
  let customerName: String

  @Dependency(\.logger) var logger
  @Dependency(\.logger["Transactions"]) var transactionsLogger

  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

  init(customerName: String = "Blob") {
    self.customerName = customerName
  }
  func userDidTapPurchaseInstrumentButton(instrument: Instrument) {
    logger.info("A customer did purchase a \(instrument.rawValue, privacy: .public)")
    Task { [customerName = self.customerName] in
      do {
        try await purchase(instrument: instrument)
        transactionsLogger.info(
          "\(customerName) did succesfully purchase a \(instrument.rawValue, privacy: .public)"
        )
      } catch {
        transactionsLogger.error(
          "\(customerName, privacy: .private) failed to purchase a \(instrument.rawValue, privacy: .public)"
        )
      }
    }
  }

  func purchase(instrument: Instrument) async throws {
    try await Task.sleep(for: .milliseconds(250))
    let randomNumber = withRandomNumberGenerator { $0.next() }
    if randomNumber.isMultiple(of: 3) {
      throw PurchaseError.badLuck(randomNumber)
    }
  }
}

struct LoggerStudyView: View {
  @ObservedObject var model: LoggerStudy
  var body: some View {
    VStack {
      HStack {
        Button {
          model.userDidTapPurchaseInstrumentButton(instrument: .guitar)
        } label: {
          Label("Buy a guitar", systemImage: "guitars")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
        }
        Button {
          model.userDidTapPurchaseInstrumentButton(instrument: .piano)
        } label: {
          Label("Buy a piano", systemImage: "pianokeys")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
        }
      }
      .buttonStyle(.borderedProminent)
      Text("Check the console while you tap the buttons above…")
    }
    .padding()
    .navigationTitle("Logger")
  }
}

struct LoggerStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoggerStudyView(model: .init())
    }
  }
}

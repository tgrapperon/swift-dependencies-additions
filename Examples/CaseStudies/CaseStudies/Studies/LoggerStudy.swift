import Dependencies
import LoggerDependency
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
    let randomNumber = self.withRandomNumberGenerator {
      Int.random(in: 0...2, using: &$0)
    }
    if randomNumber == 1 {
      throw PurchaseError.badLuck
    }
  }
}

struct LoggerStudyView: View {
  @ObservedObject var model: LoggerStudy
  var body: some View {
    VStack {
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

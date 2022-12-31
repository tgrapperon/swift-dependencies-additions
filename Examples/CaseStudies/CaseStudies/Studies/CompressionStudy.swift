import CodableDependency
import CompressionDependency
import Dependencies
import LoggerDependency
import SwiftUI

struct ProcessedText: Hashable, Codable {
  var text: String = ""
  var data: Data = .init()
}

@MainActor
final class CompressionStudy: ObservableObject {
  @Published var source: String
  @Published var processedTextJSON: String = ""
  @Published var decompressed: String = ""

  @Published var compressionRatio: Double = 1

  @Dependency(\.compress) var compress
  @Dependency(\.decompress) var decompress

  @Dependency(\.encode) var encode
  @Dependency(\.decode) var decode

  @Dependency(\.logger) var logger

  var observation: Task<Void, Never>?
  init(source: String = "Lorem ipsum dolor sit amet") {
    self.source = source
    self.observation = Task {
      do {
        for await text in self.$source.values {

          let data = text.data(using: .utf8)!
          let compressed = try await compress(data)

          if data.count * compressed.count == 0 {
            self.compressionRatio = 1
          } else {
            self.compressionRatio = Double(compressed.count) / Double(data.count)
          }

          let processedText = ProcessedText(text: text, data: compressed)

          let jsonData = try encode(processedText)
          self.processedTextJSON = String(decoding: jsonData, as: UTF8.self)

          let decoded = try decode(ProcessedText.self, from: jsonData)
          let decompressedData = try await decompress(decoded.data)
          self.decompressed = String(decoding: decompressedData, as: UTF8.self)

        }
      } catch {
        if !(error is CancellationError) {
          logger.error("Failed to process: \(error)")
        }
      }
    }
  }

  deinit {
    self.observation?.cancel()
  }
}

struct CompressionStudyView: View {
  @ObservedObject var model: CompressionStudy
  var body: some View {
    List {
      Section {
        TextEditor(text: self.$model.source)
          .frame(minHeight: 55)
      } header: {
        Text("Text")
      } footer: {
        Gauge(value: max(1 - model.compressionRatio, 0), in: 0...1) {
          Text("Compression Ratio")
        } currentValueLabel: {
          Text(model.compressionRatio.formatted(.percent.precision(.fractionLength(0))))
            .monospacedDigit()
            .animation(.none, value: model.compressionRatio)
            .transition(.identity)
        }
        .animation(.default, value: model.compressionRatio)
        .listRowBackground(Color.clear)
      }

      Section {
        TextEditor(text: .constant(self.model.processedTextJSON))
          .frame(minHeight: 88)
          .foregroundStyle(.secondary)
          .monospaced(true)
          .font(.callout)

      } header: {
        Text("Processed text in JSON")
      }
      .disabled(true)

      Section {
        TextEditor(text: .constant(self.model.decompressed))
          .frame(minHeight: 55)
          .foregroundStyle(.secondary)
      } header: {
        Text("Decoded & decompressed text")
      }.disabled(true)
    }
    .headerProminence(.increased)

    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle("Codable & Compression")
  }
}

struct CompressionStudyView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationStack {
      CompressionStudyView(
        model:
          withDependencyValues {
            let encoder = JSONEncoder()
            encoder.outputFormatting.insert(.prettyPrinted)
            encoder.outputFormatting.insert(.sortedKeys)
            $0.encode = DataEncoder(encoder)
          } operation: {
            .init()
          }
      )
    }
  }
}

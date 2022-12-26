import CompressorDependency
import Dependencies
import LoggerDependency
import SwiftUI

@MainActor
final class CompressionStudy: ObservableObject {
  @Published var source: String
  @Published var base64Data: String = ""
  @Published var compressedBase64Data: String = ""
  @Published var decompressed: String = ""

  @Dependency(\.compress) var compress
  @Dependency(\.decompress) var decompress
  @Dependency(\.logger) var logger

  var observation: Task<Void, Never>?
  init(source: String = "Lorem ipsum dolor sit amet") {
    self.source = source
    self.observation = Task {
      do {
        for await text in self.$source.values {
          let data = text.data(using: .utf8)!
          self.base64Data = data.base64EncodedString()

          let compressed = try await self.compress(data)
          self.compressedBase64Data = compressed.base64EncodedString()

          let decompressedData = try await self.decompress(compressed)
          self.decompressed = String(decoding: decompressedData, as: UTF8.self)
        }
      } catch {
        if !(error is CancellationError) {
          logger.error("Failed to compress/decompress: \(error)")
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
          .frame(minHeight: 66)
      } header: {
        HStack {
          Text("Text")
          Spacer()
          Text(self.model.source.count.formatted())
        }
      }
      
      Section {
        TextEditor(text: .constant(self.model.base64Data))
          .frame(minHeight: 66)
          .foregroundStyle(.secondary)
      } header: {
        HStack {
          Text("Text data in Base64")
          Spacer()
          Text(self.model.base64Data.count.formatted())
        }
      }
      .disabled(true)
      
      Section {
        TextEditor(text: .constant(self.model.compressedBase64Data))
          .frame(minHeight: 66)
          .foregroundStyle(.secondary)
      } header: {
        HStack {
          Text("Compressed text data in Base64")
          Spacer()
          Text(self.model.compressedBase64Data.count.formatted())
        }
      }.disabled(true)

      Section {
        TextEditor(text: .constant(self.model.decompressed))
          .frame(minHeight: 66)
          .foregroundStyle(.secondary)
      } header: {
        HStack {
          Text("Decompressed text")
          Spacer()
          Text(self.model.decompressed.count.formatted())
        }
      }.disabled(true)
    }
    .headerProminence(.increased)
    .listStyle(.grouped)
    .navigationTitle("Compression")
  }
}

struct CompressionStudyView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CompressionStudyView(model: .init())
    }
  }
}

import Dependencies
import Foundation
import IssueReporting

/// This dependency is inspired by [David Roman](https://github.com/davdroman)'s PR:
/// https://github.com/pointfreeco/swift-composable-architecture/pull/1648

extension DependencyValues {
  /// An abstraction that models `Data` reading and writing from `URL`s.
  public var dataProvider: any DataProviderProtocol {
    get { self[DataProvider.self] }
    set { self[DataProvider.self] = newValue }
  }

  /// An abstraction that models `Data` reading to `URL`s.
  public var dataReader: DataReader {
    get { dataProvider.reader }
    set { dataProvider.reader = newValue }
  }

  /// An abstraction that models `Data` writing from `URL`s.
  public var dataWriter: DataWriter {
    get { dataProvider.writer }
    set { dataProvider.writer = newValue }
  }
}

public protocol DataProviderProtocol: DataReaderProtocol & DataWriterProtocol & Sendable {}

extension DataProviderProtocol where Self == DataProvider {
  public static var system: DataProvider {
    DataProvider(reader: .system, writer: .system)
  }
  public static var unimplemented: DataProvider {
    DataProvider(reader: .unimplemented, writer: .unimplemented)
  }
}

extension DataProviderProtocol where Self == EphemeralDataProvider {
  /// An in-memory provider that is coherent when writing then reading from the same URL.
  public static func ephemeral(initialValues: @Sendable () -> [URL: Data] = { [:] })
    -> EphemeralDataProvider
  {
    EphemeralDataProvider._ephemeral(initialValues: initialValues)
  }
}

extension DataProvider: DependencyKey {
  public static var liveValue: DataProviderProtocol {
    DataProvider.system
  }
  public static var testValue: DataProviderProtocol {
    DataProvider.unimplemented
  }
  public static var previewValue: DataProviderProtocol {
    EphemeralDataProvider.ephemeral()
  }
}

public protocol DataReaderProtocol {
  var reader: DataReader { get set }
  /// Reads a data buffer from a location.
  func contentsOf(_ url: URL, options: Data.ReadingOptions) throws -> Data
}

extension DataReaderProtocol {
  public func contentsOf(_ url: URL, options: Data.ReadingOptions) throws -> Data {
    try reader.contentsOf(url, options: options)
  }
}

public protocol DataWriterProtocol {
  var writer: DataWriter { get set }
  /// Writes the contents of the data buffer to a location.
  func write(_ data: Data, to url: URL, options: Data.WritingOptions) throws
}

extension DataWriterProtocol {
  public func write(_ data: Data, to url: URL, options: Data.WritingOptions) throws {
    try writer.write(data, to: url, options: options)
  }
}

public struct DataReader: DataReaderProtocol, Sendable {
  let _contentsOfURL: @Sendable (URL, Data.ReadingOptions) throws -> Data
  public init(
    contentsOfURL: @escaping @Sendable (URL, Data.ReadingOptions) throws -> Data
  ) {
    self._contentsOfURL = contentsOfURL
  }
  public var reader: DataReader {
    get { self }
    set { self = newValue }
  }
  public func contentsOf(_ url: URL, options: Data.ReadingOptions = []) throws -> Data {
    try _contentsOfURL(url, options)
  }
}

public struct DataWriter: DataWriterProtocol, Sendable {
  let _writeToURL: @Sendable (Data, URL, Data.WritingOptions) throws -> Void
  public init(
    writeToURL: @escaping @Sendable (Data, URL, Data.WritingOptions) throws -> Void
  ) {
    self._writeToURL = writeToURL
  }
  public var writer: DataWriter {
    get { self }
    set { self = newValue }
  }
  public func write(_ data: Data, to url: URL, options: Data.WritingOptions = []) throws {
    try _writeToURL(data, url, options)
  }
}

public struct DataProvider: DataProviderProtocol {
  public var reader: DataReader
  public var writer: DataWriter

  public init(
    reader: DataReader,
    writer: DataWriter
  ) {
    self.reader = reader
    self.writer = writer
  }
}

extension DataReader {
  public static var system: DataReader {
    DataReader {
      try Data(contentsOf: $0, options: $1)
    }
  }
  public static var unimplemented: DataReader {
    .init(
      contentsOfURL: IssueReporting.unimplemented(#"@Dependency(\.dataReader.contentsOfURL)"#)
    )
  }
}

extension DataWriter {
  public static var system: DataWriter {
    DataWriter {
      try $0.write(to: $1, options: $2)
    }
  }
  public static var unimplemented: DataWriter {
    .init(
      writeToURL: IssueReporting.unimplemented(#"@Dependency(\.dataWriter.writeToURL)"#)
    )
  }
}

/// An inspectable ``DataProviderProtocol`` that can be used for testing or SwiftUI Previews.
///
/// You can create this type using ``EphemeralDataProvider/ephemeral(initialValues:)``.
public struct EphemeralDataProvider: DataProviderProtocol {
  let storage: LockIsolated<[URL: Data]>
  var provider: DataProvider

  public var reader: DataReader {
    get { self.provider.reader }
    set { self.provider.reader = newValue }
  }

  public var writer: DataWriter {
    get { self.provider.writer }
    set { self.provider.writer = newValue }
  }

  /// Extracts or assigns some `Data` at `URL`.
  public subscript(url: URL) -> Data? {
    get { storage.value[url] }
    nonmutating set {
      storage.withValue {
        $0[url] = newValue
      }
    }
  }

  public func containsData(at url: URL) -> Bool {
    self[url] != nil
  }

  public var dictionaryRepresentation: [URL: Data] {
    self.storage.value
  }
}

extension EphemeralDataProvider {
  static func _ephemeral(initialValues: @Sendable () -> [URL: Data] = { [:] })
    -> EphemeralDataProvider
  {
    let storage = LockIsolated<[URL: Data]>(initialValues())
    let reader = DataReader { url, options in
      guard let data = storage.value[url] else {
        throw NSError(
          domain: NSCocoaErrorDomain, code: 260,
          userInfo: [
            NSFilePathErrorKey: url.path,
            NSUnderlyingErrorKey: NSError(domain: NSPOSIXErrorDomain, code: 2),
          ])
      }
      return data
    }
    let writer = DataWriter {
      data, url, options in
      try storage.withValue {
        if options.contains(.withoutOverwriting), $0.keys.contains(url) {
          throw NSError(
            domain: NSCocoaErrorDomain, code: 516,
            userInfo: [
              NSFilePathErrorKey: url.path,
              NSUnderlyingErrorKey: NSError(domain: NSPOSIXErrorDomain, code: 17),
            ])
        }
        $0[url] = data
      }
    }
    return .init(
      storage: storage,
      provider: DataProvider(reader: reader, writer: writer)
    )
  }
}

extension Data {
  public func write(
    to url: URL,
    writer: any DataWriterProtocol,
    options: Data.WritingOptions = []
  )
    throws
  {
    try writer.write(self, to: url, options: options)
  }

  public init(
    contentsOf url: URL,
    reader: any DataReaderProtocol,
    options: Data.ReadingOptions = []
  )
    throws
  {
    self = try reader.contentsOf(url, options: options)
  }
}

extension String {
  public func write(
    to url: URL,
    writer: any DataWriterProtocol,
    atomically useAuxiliaryFile: Bool,
    encoding: Encoding
  ) throws {
    guard let data = self.data(using: encoding, allowLossyConversion: false) else {
      throw NSError(
        domain: NSCocoaErrorDomain, code: 517,
        userInfo: [
          NSURLErrorKey: url,
          NSStringEncodingErrorKey: encoding.rawValue,
        ])
    }
    var options: Data.WritingOptions = []
    if useAuxiliaryFile { options.insert(.atomic) }
    try writer.write(data, to: url, options: options)
  }
  /// Produces a string created by reading data from a given URL interpreted using a given encoding.
  public init(
    contentsOf url: URL,
    reader: any DataReaderProtocol,
    encoding enc: String.Encoding
  ) throws {
    let data = try Data(contentsOf: url, reader: reader)
    guard let string = String(data: data, encoding: enc) else {
      throw NSError(
        domain: NSCocoaErrorDomain, code: 264,
        userInfo: [
          NSFilePathErrorKey: url.path
        ])
    }
    self = string
  }

  /// Produces a string created by reading data from a given URL and returns by reference the
  /// encoding used to interpret the data.
  public init(
    contentsOf url: URL,
    reader: any DataReaderProtocol,
    usedEncoding enc: inout String.Encoding
  ) throws {
    let data = try Data(contentsOf: url, reader: reader)
    if let string = String(data: data, encoding: enc) {
      self = string
      return
    }
    // Try to be conservative. I don't know what algorithm they use for
    // `String(contentsOf:usedEncoding)`
    var encodings: [String.Encoding] = [
      .utf8, .utf16, .utf32, .windowsCP1252,
    ]

    for encoding in String.availableStringEncodings {
      if !encodings.contains(encoding) { encodings.append(encoding) }
    }
    encodings.removeAll {
      $0 == enc || !String.availableStringEncodings.contains($0)
    }
    for encoding in encodings {
      if let string = String(data: data, encoding: encoding) {
        enc = encoding
        self = string
        return
      }
    }
    throw NSError(
      domain: NSCocoaErrorDomain, code: 264,
      userInfo: [
        NSFilePathErrorKey: url.path
      ])
  }

  public init(
    contentsOf url: URL,
    reader: any DataReaderProtocol
  ) throws {
    let data = try Data(contentsOf: url, reader: reader)
    guard let string = String(data: data, encoding: .utf8) else {
      throw NSError(
        domain: NSCocoaErrorDomain, code: 264,
        userInfo: [
          NSFilePathErrorKey: url.path
        ])
    }
    self = string
  }
}

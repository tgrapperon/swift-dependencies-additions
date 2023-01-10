#if canImport(Compression)
  import Compression
  import Dependencies
  import Foundation

  func defaultSync(_ operation: FilterOperation) -> @Sendable (
    _ data: Data, _ algorithm: Algorithm
  ) throws
    -> Data
  {
    let operation = UncheckedSendable(operation)
    return { data, algorithm in
      let pageSize = 512

      var processed = Data()
      var index = 0
      let count = data.count
      let inputFilter = try InputFilter(
        operation.wrappedValue,
        using: algorithm,
        bufferCapacity: max(65635, pageSize)
      ) {
        let rangeLength = min($0, count - index)
        let subdata = data[index..<index + rangeLength]
        index += rangeLength
        return subdata
      }
      while let page = try inputFilter.readData(ofLength: pageSize) {
        processed.append(page)
      }
      return processed
    }
  }

  func defaultAsync(_ operation: FilterOperation) -> @Sendable (
    _ data: Data, _ algorithm: Algorithm
  ) async throws -> Data {
    let operation = UncheckedSendable(operation)
    return { data, algorithm in
      let pageSize = 512
      let asyncOperationsPeriod = 10

      var processed = Data()
      var index = 0
      let count = data.count
      let inputFilter = try InputFilter(
        operation.wrappedValue,
        using: algorithm,
        bufferCapacity: max(65635, pageSize)
      ) {
        let rangeLength = min($0, count - index)
        let subdata = data[index..<index + rangeLength]
        index += rangeLength
        return subdata
      }
      var iteration: Int = 0
      while let page = try inputFilter.readData(ofLength: pageSize) {
        if iteration.isMultiple(of: asyncOperationsPeriod) {
          try Task.checkCancellation()
          await Task.yield()
        }
        processed.append(page)
        iteration += 1
      }
      return processed
    }
  }
#endif

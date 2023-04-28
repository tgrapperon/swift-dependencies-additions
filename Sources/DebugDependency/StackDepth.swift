import Dependencies
import LoggerDependency
import Foundation

#if canImport(OSLog)
  import OSLog
#endif

public struct StackDepth {
  public let stackSize: UInt
  public let used: UInt

  public var available: UInt { stackSize - used }
  public var usedFraction: Double { Double(used) / Double(stackSize) }

  public init() {
    let thread = pthread_self()
    let stackAddress = UInt(bitPattern: pthread_get_stackaddr_np(thread))
    var used: UInt = 0
    withUnsafeMutablePointer(to: &used) {
      let pointerAddress = UInt(bitPattern: $0)
      // Stack goes down on x86/64 and arm, but we rectify the result in any case this code
      // executes on another architecture using a different convention.
      $0.pointee =
        stackAddress > pointerAddress
        ? stackAddress - pointerAddress
        : pointerAddress - stackAddress
    }
    self.stackSize = UInt(pthread_get_stacksize_np(thread))
    self.used = used
  }

  public func callAsFunction(
    label: String? = nil,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.log(label: label, fileID: fileID, line: line)
  }

  func log(
    label: String?,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) {
    let message = self.message(label: label, fileID: fileID, line: line)
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      #if canImport(OSLog)
        @Dependency(\.logger) var log: Logger
        log.debug("\(message)")
      #else
        Swift.print(message)
      #endif
    } else {
      Swift.print(message)
    }
  }

  func message(label: String?, fileID: StaticString, line: UInt) -> String {
    func separated(_ number: UInt) -> String {
      var separated = [String]()
      for (index, char) in "\(number)".reversed().enumerated() {
        if index > 0, index.isMultiple(of: 3) {
          separated.append(",")
        }
        separated.append("\(char)")
      }
      return separated.reversed().joined()
    }

    func filename(_ fileID: StaticString) -> String {
      "\(fileID)".components(separatedBy: "/").last!.replacingOccurrences(of: ".swift", with: "")
    }
    
    let prefix = label.map { "\($0)" } ?? "\(filename(fileID)):l\(line)"

    return """
      Stack Depth - \(prefix) - \
      \(separated(self.used))/\(separated(self.stackSize)) bytes \
      (\(String(format: "%.2f%%", usedFraction * 100)))
      """
  }
}

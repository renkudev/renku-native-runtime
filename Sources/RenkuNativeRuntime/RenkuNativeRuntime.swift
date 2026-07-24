import Foundation
import RenkuNativeShim

public struct RenkuNativeRuntimeError: Error, Equatable, Sendable {
  public let message: String

  public init(message: String) {
    self.message = message
  }
}

extension RenkuNativeRuntimeError: CustomStringConvertible {
  public var description: String { message }
}

public final class RenkuNativeRuntime {
  private let handle: OpaquePointer

  public init(bytecode: Data) throws {
    let handle = bytecode.withUnsafeBytes { bytes in
      renku_native_runtime_create(
        bytes.bindMemory(to: UInt8.self).baseAddress,
        bytes.count
      )
    }
    guard let handle else {
      throw Self.lastError()
    }
    self.handle = handle
  }

  deinit {
    renku_native_runtime_destroy(handle)
  }

  public func reload(bytecode: Data) throws {
    let succeeded = bytecode.withUnsafeBytes { bytes in
      renku_native_runtime_reload(
        handle,
        bytes.bindMemory(to: UInt8.self).baseAddress,
        bytes.count
      )
    }
    guard succeeded == 1 else {
      throw Self.lastError()
    }
  }

  public func render() throws -> String {
    try Self.string(from: renku_native_runtime_render(handle))
  }

  public func invoke(_ action: Int32, payload: String = "null") throws -> String {
    try payload.withCString { payload in
      try Self.string(from: renku_native_runtime_invoke(handle, action, payload))
    }
  }

  private static func string(from pointer: UnsafePointer<CChar>?) throws -> String {
    guard let pointer else {
      throw lastError()
    }
    return String(cString: pointer)
  }

  private static func lastError() -> RenkuNativeRuntimeError {
    RenkuNativeRuntimeError(message: String(cString: renku_native_runtime_last_error()))
  }
}

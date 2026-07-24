import Foundation
import RenkuNativeRuntime

let bytecodeURL = Bundle.module.url(forResource: "runtime", withExtension: "hbc")!
let runtime = try RenkuNativeRuntime(bytecode: Data(contentsOf: bytecodeURL))

guard
  try runtime.render() == "ready",
  try runtime.invoke(7) == "7:null",
  try runtime.invoke(8, payload: "true") == "8:true",
  try runtime.invoke(9, payload: #"{"selection":"detail"}"#) == #"9:{"selection":"detail"}"#
else {
  fatalError("Hermes returned an unexpected result")
}

print("Renku Native Runtime initialized")

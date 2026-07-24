import Foundation
import RenkuNativeRuntime

let bytecodeURL = Bundle.module.url(forResource: "runtime", withExtension: "hbc")!
let runtime = try RenkuNativeRuntime(bytecode: Data(contentsOf: bytecodeURL))

guard try runtime.render() == "ready", try runtime.invoke(7) == "7" else {
  fatalError("Hermes returned an unexpected result")
}

print("Renku Native Runtime initialized")


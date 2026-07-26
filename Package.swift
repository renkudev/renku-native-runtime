// swift-tools-version: 6.0

import Foundation
import PackageDescription

let localArtifact = ProcessInfo.processInfo.environment["RENKU_NATIVE_LOCAL_XCFRAMEWORK"]

let hermesVM: Target = if let localArtifact {
  .binaryTarget(name: "HermesVM", path: localArtifact)
} else {
  .binaryTarget(
    name: "HermesVM",
    url: "https://github.com/renkudev/renku-native/releases/download/0.1.2/hermesvm.xcframework.zip",
    checksum: "6d4a5d3cd6d5b3fdfd7eb9d578efcd156a11085731ae58b7dcf17cfdcf5b51b5"
  )
}

let package = Package(
  name: "RenkuNativeRuntime",
  platforms: [
    .macOS("27.0"),
    .iOS("27.0"),
  ],
  products: [
    .library(name: "RenkuNativeRuntime", targets: ["RenkuNativeRuntime"]),
  ],
  targets: [
    hermesVM,
    .target(
      name: "RenkuNativeShim",
      dependencies: ["HermesVM"],
      exclude: ["hermes-include"],
      publicHeadersPath: "include",
      cxxSettings: [
        .define("HERMES_IS_MOBILE_BUILD"),
        .define("JSI_UNSTABLE"),
        .headerSearchPath("hermes-include"),
      ]
    ),
    .target(
      name: "RenkuNativeRuntime",
      dependencies: ["RenkuNativeShim"]
    ),
    .executableTarget(
      name: "RenkuNativeRuntimeProbe",
      dependencies: ["RenkuNativeRuntime"],
      exclude: ["Fixtures/runtime.js"],
      resources: [.copy("Fixtures/runtime.hbc")]
    ),
  ],
  cxxLanguageStandard: .cxx20
)

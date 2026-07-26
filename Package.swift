// swift-tools-version: 6.0

import Foundation
import PackageDescription

let localArtifact = ProcessInfo.processInfo.environment["RENKU_NATIVE_LOCAL_XCFRAMEWORK"]

let hermesVM: Target = if let localArtifact {
  .binaryTarget(name: "HermesVM", path: localArtifact)
} else {
  .binaryTarget(
    name: "HermesVM",
    url: "https://github.com/renkudev/renku-native/releases/download/0.1.6/hermesvm.xcframework.zip",
    checksum: "e2fa6e7be8cfb4c1c6fc6bad00c2520f7790dcd90a293000fc6f9f18e4bf3c57"
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

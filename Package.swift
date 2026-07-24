// swift-tools-version: 6.0

import Foundation
import PackageDescription

let localArtifact = ProcessInfo.processInfo.environment["RENKU_NATIVE_LOCAL_XCFRAMEWORK"]

let hermesVM: Target = if let localArtifact {
  .binaryTarget(name: "HermesVM", path: localArtifact)
} else {
  .binaryTarget(
    name: "HermesVM",
    url: "https://github.com/renkudev/renku-native-runtime/releases/download/0.0.0/hermesvm.xcframework.zip",
    checksum: "0000000000000000000000000000000000000000000000000000000000000000"
  )
}

let package = Package(
  name: "RenkuNativeRuntime",
  platforms: [
    .macOS("13.3"),
    .iOS("16.4"),
    .tvOS("16.4"),
    .visionOS(.v1),
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

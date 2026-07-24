# Renku Native Runtime

The managed Hermes runtime used by Renku native applications.

The Swift package exposes `RenkuNativeRuntime`, backed by a pinned Hermes
XCFramework containing these Apple platform variants:

- macOS
- iOS and iOS Simulator
- Mac Catalyst
- tvOS and tvOS Simulator
- visionOS and visionOS Simulator

The pinned Hermes revision does not provide a watchOS build.

## Add the package

Add this repository as a Swift package dependency and link the
`RenkuNativeRuntime` product.

```swift
.package(
  url: "https://github.com/renkudev/renku-native-runtime.git",
  from: "0.1.0"
)
```

## Release model

Each semantic version tag points at a `Package.swift` whose binary target
references an immutable `hermesvm.xcframework.zip` asset from the matching
GitHub Release. The release workflow builds each platform slice independently,
assembles the XCFramework, validates the package, computes its checksum, and
updates the manifest before tagging the release.

The same release also contains `hermesc-macos-arm64.tar.gz` and its SHA-256
sidecar. Renku's build tooling downloads this host compiler separately from
Swift Package Manager. Building both artifacts from the same pinned Hermes
revision makes each release one compiler/runtime compatibility unit.

For a compiler-only patch release, set `reuse_runtime_version` to the existing
compatible release. The workflow republishes that release's verified,
byte-identical XCFramework under the new tag, skips all runtime slice builds,
and still validates bytecode produced by the new compiler against the reused
runtime.

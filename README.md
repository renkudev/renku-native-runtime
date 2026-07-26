# Renku Native Runtime

The managed Hermes runtime used by Renku native applications.

The Swift package exposes `RenkuNativeRuntime`, backed by a pinned Hermes
XCFramework, for these supported Renku destinations:

- macOS 27 or later
- iOS and iPadOS 27 or later, including the iOS Simulator

## Add the package

Add this repository as a Swift package dependency and link the
`RenkuNativeRuntime` product.

```swift
.package(
  url: "https://github.com/renkudev/renku-native.git",
  from: "0.1.0"
)
```

## Release model

Each semantic version tag points at a `Package.swift` whose binary target
references an immutable `hermesvm.xcframework.zip` asset from the matching
GitHub Release. The release workflow builds the native macOS, iOS device, and
iOS Simulator slices independently, assembles the XCFramework, validates those
three destinations, computes its checksum, and updates the manifest before
tagging the release.

The same release also contains `hermesc-macos-arm64.tar.gz` and its SHA-256
sidecar. Renku's build tooling downloads this host compiler separately from
Swift Package Manager. Building both artifacts from the same pinned Hermes
revision makes each release one compiler/runtime compatibility unit.
Every release rebuilds and publishes both artifacts together.

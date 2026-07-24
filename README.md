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


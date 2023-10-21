// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "AdaptiveCoordinator",
  platforms: [
    .iOS(.v14),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "AdaptiveCoordinator",
      targets: ["AdaptiveCoordinator"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-case-paths.git",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.0.5") // or `.upToNextMajor
    ),
  ],
  targets: [
    .target(
      name: "AdaptiveCoordinator",
      dependencies: [
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "AdaptiveCoordinatorTests",
      dependencies: ["AdaptiveCoordinator"]
    ),
  ]
)

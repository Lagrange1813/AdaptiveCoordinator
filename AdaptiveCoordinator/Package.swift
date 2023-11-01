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
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.0.5")
    ),
  ],
  targets: [
    .target(
      name: "AdaptiveCoordinator",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "AdaptiveCoordinatorTests",
      dependencies: ["AdaptiveCoordinator"]
    ),
  ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "AdaptiveCoordinator",
  platforms: [
    .iOS(.v14),
    .macOS(.v12),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "AdaptiveCoordinator",
      targets: ["AdaptiveCoordinator"]
    ),
  ],
  targets: [
    .target(
      name: "AdaptiveCoordinator"),
    .testTarget(
      name: "AdaptiveCoordinatorTests",
      dependencies: ["AdaptiveCoordinator"]
    ),
  ]
)

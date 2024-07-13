// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ColorUtilities",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ColorUtilities",
            targets: ["ColorUtilities"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ColorUtilities",
            dependencies: []),
        .testTarget(
            name: "ColorUtilitiesTests",
            dependencies: ["ColorUtilities"])
    ]
)

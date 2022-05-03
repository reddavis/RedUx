// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Quoin",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0")
    ],
    products: [
        .library(
            name: "Quoin",
            targets: ["Quoin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/reddavis/Asynchrone", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "Quoin",
            dependencies: ["Asynchrone"],
            path: "Quoin",
            exclude: []
        ),
        .testTarget(
            name: "QuoinTests",
            dependencies: ["Quoin"],
            path: "QuoinTests"
        )
    ]
)

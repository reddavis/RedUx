// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RedUx",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0")
    ],
    products: [
        .library(
            name: "RedUx",
            targets: ["RedUx"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/reddavis/Asynchrone", from: "0.17.0")
    ],
    targets: [
        .target(
            name: "RedUx",
            dependencies: ["Asynchrone"],
            path: "RedUx",
            exclude: []
        ),
        .testTarget(
            name: "RedUxTests",
            dependencies: ["RedUx"],
            path: "RedUxTests"
        )
    ]
)

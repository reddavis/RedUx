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
        ),
        .library(
            name: "RedUxTestUtilities",
            targets: ["RedUxTestUtilities"]
        )
    ],
    targets: [
        .target(
            name: "RedUx",
            path: "RedUx",
            exclude: ["Supporting Files/RedUx.docc"]
        ),
        .target(
            name: "RedUxTestUtilities",
            path: "RedUxTestUtilities",
            dependencies: ["RedUx"]
        ),
        .testTarget(
            name: "RedUxTests",
            dependencies: ["RedUx"],
            path: "RedUxTests"
        )
    ]
)

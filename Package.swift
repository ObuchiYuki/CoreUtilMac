// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreUtilMac",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "CoreUtilMac", targets: ["CoreUtilMac"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ObuchiYuki/Promise", branch: "main")
    ],
    targets: [
        .target(name: "CoreUtilMac", dependencies: [
            .product(name: "Promise", package: "Promise")
        ]),
        .testTarget(name: "CoreUtilMacTests", dependencies: [
            "CoreUtilMac"
        ]),
    ]
)


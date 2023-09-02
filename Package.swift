// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "USDZScanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "USDZScanner",
            targets: ["USDZScanner"]),
    ],
    targets: [
        .target(
            name: "USDZScanner",
            resources: [.copy("Resources/")])
    ]
)

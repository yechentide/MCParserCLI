// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCParserCLI",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "mcp", targets: ["MCParserCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/yechentide/LvDBWrapper", branch: "main"),
        .package(url: "https://github.com/ipshing/SwiftNbt", from: "1.0.1")
    ],
    targets: [
        //.testTarget(name: "MCParserCLITests", dependencies: ["MCParserCLICore"]),
        .executableTarget(name: "MCParserCLI", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "LvDBWrapper", package: "LvDBWrapper"),
            .product(name: "SwiftNbt", package: "SwiftNbt")
        ]),
    ]
)

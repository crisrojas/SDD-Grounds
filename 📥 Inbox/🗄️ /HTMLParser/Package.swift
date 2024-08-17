// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTMLParser",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTMLParser",
            targets: ["HTMLParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", .upToNextMajor(from: "2.7.4")),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump/", .upToNextMajor(from: "1.3.3")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HTMLParser",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "CustomDump", package: "swift-custom-dump")
            ]
        ),
        .testTarget(
            name: "HTMLParserTests",
            dependencies: ["HTMLParser"]),
    ]
)

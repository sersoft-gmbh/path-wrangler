// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "path-wrangler",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CorePathWrangler",
            targets: ["CorePathWrangler"]),
        .library(
            name: "PathWrangler",
            targets: ["PathWrangler"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "CPathWrangler"),
        .target(
            name: "CorePathWrangler",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                "CPathWrangler",
        ]),
        .target(
            name: "PathWrangler",
            dependencies: ["CorePathWrangler"]),
        .testTarget(
            name: "CorePathWranglerTests",
            dependencies: ["CorePathWrangler"]),
        .testTarget(
            name: "PathWranglerTests",
            dependencies: ["PathWrangler"]),
    ]
)

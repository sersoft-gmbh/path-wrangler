// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PathWrangler",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CorePathWrangler",
            targets: ["CorePathWrangler"]),
        .library(
            name: "PathWrangler",
            targets: ["PathWrangler"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "StdLibAlgorithms"),
        .target(name: "CPathWrangler"),
        .target(
            name: "CorePathWrangler",
            dependencies: [
                "StdLibAlgorithms",
                "CPathWrangler",
        ]),
        .target(
            name: "PathWrangler",
            dependencies: ["CorePathWrangler"]),
        .testTarget(
            name: "StdLibAlgorithmsTests",
            dependencies: ["StdLibAlgorithms"]),
        .testTarget(
            name: "CorePathWranglerTests",
            dependencies: ["CorePathWrangler"]),
        .testTarget(
            name: "PathWranglerTests",
            dependencies: ["PathWrangler"]),
    ]
)

// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: Array<SwiftSetting> = [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("IsolatedDefaultValues"),
    .enableUpcomingFeature("DeprecateApplicationMain"),
    .enableExperimentalFeature("StrictConcurrency"),
    .enableExperimentalFeature("GlobalConcurrency"),
    .enableExperimentalFeature("AccessLevelOnImport"),
]

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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
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
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "PathWrangler",
            dependencies: ["CorePathWrangler"],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "CorePathWranglerTests",
            dependencies: ["CorePathWrangler"],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "PathWranglerTests",
            dependencies: ["PathWrangler"],
            swiftSettings: swiftSettings),
    ]
)

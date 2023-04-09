// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

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
        .package(url: "https://github.com/apple/swift-algorithms.git", "0.1.0"..<"2.0.0"),
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

if ProcessInfo.processInfo.environment["ENABLE_DOCC_SUPPORT"] == "1" {
    package.dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
}

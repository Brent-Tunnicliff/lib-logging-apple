// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Package

let package = Package(
    name: "DemoCommon",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DemoCommon",
            targets: ["DemoCommon"]
        )
    ],
    dependencies: [
        .package(path: "../../."),
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DemoCommon",
            dependencies: [
                .product(name: "Logging", package: "lib-logging-apple"),
                .product(name: "LoggingUI", package: "lib-logging-apple"),
            ]
        )
    ]
)

// MARK: - Common target settings

// Sets values that are common for every target.
for target in package.targets {

    // MARK: Plugins

    let plugins = target.plugins ?? []
    target.plugins = plugins + [
        .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")
    ]

    // MARK: Swift compliler settings

    let swiftSettings = target.swiftSettings ?? []
    target.swiftSettings = swiftSettings + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
    ]
}

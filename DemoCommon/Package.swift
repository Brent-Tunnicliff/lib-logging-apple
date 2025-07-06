// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let swiftSettings: [PackageDescription.SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "DemoCommon",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
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
        .package(path: "../."),
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
            ],
            swiftSettings: swiftSettings,
            plugins: [
                .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")
            ]
        )
    ]
)

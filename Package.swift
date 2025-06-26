// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import PackageDescription

private let swiftSettings: [PackageDescription.SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
]

private let lintBuildPlugin: Target.PluginUsage = .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")

let package = Package(
    name: "Logging",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "Logging",
            targets: ["Logging"]
        ),
        .library(
            name: "LoggingUI",
            targets: ["LoggingUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Brent-Tunnicliff/lib-userdefaults-apple", exact: "1.0.0-beta.2"),
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "LoggingCore",
            dependencies: [
                .product(name: "UserDefaultsHelpers", package: "lib-userdefaults-apple")
            ],
            swiftSettings: swiftSettings,
            plugins: [
                lintBuildPlugin
            ]
        ),
        .target(
            name: "Logging",
            dependencies: ["LoggingCore"],
            swiftSettings: swiftSettings,
            plugins: [
                lintBuildPlugin
            ]
        ),
        .target(
            name: "LoggingUI",
            dependencies: [
                "LoggingCore",
                .product(name: "UserDefaultsHelpers", package: "lib-userdefaults-apple")
            ],
            resources: [
                .copy("Resources/Settings.bundle"),
                .copy("Resources/InputFileList.xcfilelist"),
                .copy("Resources/OutputFileList.xcfilelist"),
            ],
            swiftSettings: swiftSettings,
            plugins: [
                lintBuildPlugin
            ]
        ),
        .testTarget(
            name: "LoggingTests",
            dependencies: ["Logging"],
            swiftSettings: swiftSettings,
            plugins: [
                lintBuildPlugin
            ]
        ),
        .testTarget(
            name: "LoggingCoreTests",
            dependencies: ["LoggingCore"],
            swiftSettings: swiftSettings,
            plugins: [
                lintBuildPlugin
            ]
        ),
    ]
)

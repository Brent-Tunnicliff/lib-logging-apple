// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import PackageDescription

// MARK: - Package

let package = Package(
    name: "Logging",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
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
        // Only adding LoggingCore as a product so I can enable test coverage for it.
        // None of its interfaces are expected to be public.
        .library(
            name: "LoggingCore",
            targets: ["LoggingCore"]
        ),
//        .plugin(
//            name: "LoggingSettingsGeneratorBuildPlugin",
//            targets: ["LoggingSettingsGeneratorBuildPlugin"]
//        ),
//        .plugin(
//            name: "LoggingSettingsGeneratorCommandPlugin",
//            targets: ["LoggingSettingsGeneratorCommandPlugin"]
//        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Brent-Tunnicliff/lib-userdefaults-apple", exact: "1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "LoggingCore"),
        .testTarget(
            name: "LoggingCoreTests",
            dependencies: [
                "LoggingCore",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .target(
            name: "Logging",
            dependencies: ["LoggingCore"]
        ),
        .testTarget(
            name: "LoggingTests",
            dependencies: [
                "Logging",
                .product(name: "Algorithms", package: "swift-algorithms"),
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
            swiftSettings: [
                // UI library, so MainActor default makes sense.
                .defaultIsolation(MainActor.self),
            ]
        ),
//        .executableTarget(name: "LoggingSettingsGenerator"),
//        .plugin(
//            name: "LoggingSettingsGeneratorBuildPlugin",
//            capability: .buildTool,
//            dependencies: [
//                "LoggingSettingsGenerator"
//            ]
//        ),
//        .plugin(
//            name: "LoggingSettingsGeneratorCommandPlugin",
//            capability: .command(
//                intent: .custom(
//                    verb: "generate-logging-settings",
//                    description: "Generates Logging settings and injects them into the app 'Settings.bundle'"
//                ),
//                permissions: []
//            )
//        ),
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
        .strictMemorySafety(),

        // Feature flags

        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]
}

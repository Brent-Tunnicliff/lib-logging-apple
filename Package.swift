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
        .plugin(
            name: "LoggingSettingsGeneratorCommandPlugin",
            targets: ["LoggingSettingsGeneratorCommandPlugin"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/alexey1312/SnapshotTestingHEIC.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Brent-Tunnicliff/lib-ui-apple", branch: "main"),
        .package(url: "https://github.com/Brent-Tunnicliff/lib-userdefaults-apple", exact: "1.0.0-beta.2"),
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.18.0")),
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
                .product(name: "CommonUI", package: "lib-ui-apple"),
                .product(name: "UserDefaultsHelpers", package: "lib-userdefaults-apple")
            ],
            resources: [
                .process("Localizable.xcstrings")
            ],
            swiftSettings: [
                // UI library, so MainActor default makes sense.
                .defaultIsolation(MainActor.self),
            ]
        ),
        .testTarget(
            name: "LoggingUISnapshotTests",
            dependencies: [
                "LoggingUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SnapshotTestingHEIC", package: "SnapshotTestingHEIC"),
            ],
            swiftSettings: [
                // UI library, so MainActor default makes sense.
                .defaultIsolation(MainActor.self),
            ]
        ),
        .executableTarget(
            name: "logging-settings-generator",
            path: "Sources/LoggingSettingsGenerator",
            resources: [
                .copy("Resources/Settings.bundle")
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ]
        ),
        .plugin(
            name: "LoggingSettingsGeneratorCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate-logging-settings",
                    description: "Generates Logging settings and injects them into the app 'Settings.bundle'"
                ),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Manages the values of the 'Logging' values in 'Settings.bundle'"
                    )
                ]
            ),
            dependencies: [.target(name: "logging-settings-generator")]
        ),
    ]
)

// MARK: - Common target settings

// Sets values that are common for every target.
// Plugins cannot contain plugins or swift settings.
for target in package.targets where target.type != .plugin {
    // MARK: Plugins

    let commonPlugins: [PackageDescription.Target.PluginUsage] = [
        .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")
    ]

    target.plugins = (target.plugins ?? []) + commonPlugins

    // MARK: Swift compliler settings

    let commonSwiftSettings: [PackageDescription.SwiftSetting] = [
        // Optional: Set defaultIsolation to `MainActor` if desired.
        // Probably only useful in a UI heavy package.
        // .defaultIsolation(MainActor.self),

        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + commonSwiftSettings
}

// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import PackagePlugin

@main
struct LoggingSettingsGeneratorCommandPlugin: CommandPlugin {
    private let executableName = "logging-settings-generator"

    func performCommand(context: PluginContext, arguments: [String]) throws {
        let executable = try context.tool(named: executableName).url
        let sourceFileLists = context.package.sourceModules.map(\.sourceFiles)
        try generateLoggingSettings(
            executable: executable,
            sourceFileLists: sourceFileLists
        )
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension LoggingSettingsGeneratorCommandPlugin: XcodeCommandPlugin {
        func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
            let executable = try context.tool(named: executableName).url
            let sourceFileLists = context.xcodeProject.targets.map(\.inputFiles)
            try generateLoggingSettings(
                executable: executable,
                sourceFileLists: sourceFileLists
            )
        }
    }
#endif

extension LoggingSettingsGeneratorCommandPlugin {
    fileprivate func generateLoggingSettings(
        executable: URL,
        sourceFileLists: [PackagePlugin.FileList]
    ) throws {
        let settingsBundles = sourceFileLists.flatMap { fileList in
            fileList.filter { $0.url.lastPathComponent == "Settings.bundle" }
        }

        guard !settingsBundles.isEmpty else {
            throw PluginError.cannotFindSettingsBundle
        }

        for outputSettingsBundle in settingsBundles {
            let process = Process()
            process.executableURL = executable
            process.arguments = [
                "-o",
                outputSettingsBundle.url.absoluteString
            ]

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                print("Copied to `\(outputSettingsBundle.url.absoluteString)`")
            } else {
                print(
                    "Failed with status \(process.terminationStatus) for `\(outputSettingsBundle.url.absoluteString)`"
                )
                exit(EXIT_FAILURE)
            }
        }
    }

    private enum PluginError: Error {
        case sourceModuleMissing
        case cannotFindSettingsBundle
    }
}

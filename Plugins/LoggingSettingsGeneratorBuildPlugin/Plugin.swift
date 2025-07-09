//// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>
//
//import Foundation
//import PackagePlugin
//
//@main
//struct LoggingSettingsGeneratorBuildPlugin: BuildToolPlugin {
//    private let executableName = "LoggingSettingsGenerator"
//
//    func createBuildCommands(
//        context: PluginContext,
//        target: any Target
//    ) async throws -> [Command] {
//        try createCommands(
//            executable: context.tool(named: executableName)
//        )
//    }
//}
//
//#if canImport(XcodeProjectPlugin)
//    import XcodeProjectPlugin
//
//    extension LoggingSettingsGeneratorBuildPlugin: XcodeBuildToolPlugin {
//        func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
//            try createCommands(
//                executable: context.tool(named: executableName)
//            )
//        }
//    }
//
//#endif
//
//extension LoggingSettingsGeneratorBuildPlugin {
//    private func createCommands(
//        executable: PackagePlugin.PluginContext.Tool
//    ) throws -> [Command] {
//        [
//            .buildCommand(
//                displayName: "Generating logging settings",
//                executable: executable.url,
//                arguments: [],
//                environment: [:],
//                inputFiles: [],
//                outputFiles: []
//            )
//        ]
//    }
//}

//// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>
//
//import PackagePlugin
//
//@main
//struct LoggingSettingsGeneratorCommandPlugin: CommandPlugin {
//    func performCommand(context: PluginContext, arguments: [String]) throws {
//        generateLoggingSettings()
//    }
//}
//
//#if canImport(XcodeProjectPlugin)
//    import XcodeProjectPlugin
//
//    extension LoggingSettingsGeneratorCommandPlugin: XcodeCommandPlugin {
//        func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
//            generateLoggingSettings()
//        }
//    }
//#endif
//
//extension LoggingSettingsGeneratorCommandPlugin {
//    fileprivate func generateLoggingSettings() {
//
//    }
//}

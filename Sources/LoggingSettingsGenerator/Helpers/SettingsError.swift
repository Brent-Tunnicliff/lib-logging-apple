// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

enum SettingsError: Error {
    case cannotFindRootFileOfOutput
    case outputArgumentNotABundle
    case unableToFindSettingsBundle
    case unableToParseOutputRootFile
}

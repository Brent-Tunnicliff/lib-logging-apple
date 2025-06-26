// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

enum Argument {
    case help
    case files([File])
}

// MARK: - File

extension Argument {
    struct File {
        let input: URL
        let output: URL
    }
}

// MARK: - ArgumentsError

enum ArgumentsError: Error {
    case duplicateFlag(String)
    case invalidURL(String)
    case flagMissingValue(String)
    case requiredFlagsMissing([String])
}

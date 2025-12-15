// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol ArgumentService {
    func parseArgument(from arguments: [String]) async throws -> Argument
}

enum ArgumentServiceError: Error {
    case duplicateFlag(String)
    case invalidURL(String)
    case flagMissingValue(String)
    case requiredFlagsMissing([String])
}

extension ArgumentService {
    var helpMessage: String {
        """
        Copies the Logging Settings values to the output location.

        Options:
        \(Flag.allCases.map(\.helpText).joined(separator: "\n"))
        """
    }

    func parseArgument() async throws -> Argument {
        try await parseArgument(from: CommandLine.arguments)
    }
}

final class DefaultArgumentService: ArgumentService, Sendable {
    func parseArgument(from arguments: [String]) async throws -> Argument {
        // If we arguments contain help, then just return right away
        guard !arguments.contains(where: { Flag(rawValue: $0) == .help }) else {
            return .help
        }

        var values: [Flag: String] = [:]
        for (offset, argument) in arguments.enumerated() {
            guard let flag = Flag(rawValue: argument) else {
                continue
            }

            guard values[flag] == nil else {
                throw ArgumentError.duplicateFlag(flag)
            }

            values[flag] = try getNextValue(flag: flag, offset: offset, inputs: arguments)
        }

        guard let outputValue = values[.output] else {
            throw ArgumentError.flagMissingValue(.output)
        }

        guard let output = URL(string: outputValue) else {
            throw ArgumentError.invalidURL(outputValue)
        }

        return .output(output)
    }

    private func getNextValue(flag: Flag, offset: Int, inputs: [String]) throws -> String {
        let nextOffset = offset + 1
        guard nextOffset < inputs.count else {
            throw ArgumentError.flagMissingValue(flag)
        }

        let nextValue = inputs[nextOffset]
        // If next value is a flag, then the value for the last value is missing.
        guard Flag(rawValue: nextValue) == nil else {
            throw ArgumentError.flagMissingValue(flag)
        }

        return nextValue
    }
}

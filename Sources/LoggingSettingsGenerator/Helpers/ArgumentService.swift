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
        ""
    }

    func parseArgument() async throws -> Argument {
//        try await parseArgument(from: CommandLine.arguments)
        try await parseArgument(from: ["-i", "path/to/input", "-o", "path/to/output"])
    }
}

final class DefaultArgumentService: ArgumentService, Sendable {
    private let fileService: any FileService

    init(fileService: any FileService) {
        self.fileService = fileService
    }

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
                throw ArgumentsError.duplicateFlag(argument)
            }

            values[flag] = try Self.getNextValue(flag: flag, offset: offset, inputs: arguments)
        }

        let missingFlags = [Flag.input, .output].filter { values[$0] == nil }
        guard
            missingFlags.isEmpty,
            let inputValue = values[.input],
            let outputValue = values[.output]
        else {
            throw ArgumentsError.requiredFlagsMissing(missingFlags.map(\.description))
        }

        let inputFiles = try await fileService.contentsOfDirectory(atPath: inputValue)
            .map {
                guard let input = URL(string: $0) else {
                    throw ArgumentsError.invalidURL($0)
                }

                return Argument.File(
                    input: input,
                    // TODO: Work out output
                    output: input
                )
            }

        return .files(inputFiles)
    }

    private static func getNextValue(flag: Flag, offset: Int, inputs: [String]) throws -> String {
        let nextOffset = offset + 1
        guard nextOffset < inputs.count else {
            throw ArgumentsError.flagMissingValue(flag.description)
        }

        let nextValue = inputs[nextOffset]
        // If next value is a flag, then
        guard Flag(rawValue: nextValue) == nil else {
            throw ArgumentsError.flagMissingValue(flag.description)
        }

        return nextValue
    }
}

final class StubArgumentService: ArgumentService {
    func parseArgument(from arguments: [String]) -> Argument {
        .help
    }
}

// MARK: - Flag

private enum Flag {
    case help
    case input
    case output
}

extension Flag: CaseIterable {}

extension Flag: CustomStringConvertible {
    var description: String {
        keys.joined(separator: ", ")
    }
}

extension Flag {
    init?(rawValue: String) {
        guard let flag = Flag.allCases.first(where: { $0.keys.contains(rawValue) }) else {
            return nil
        }

        self = flag
    }
}

extension Flag {
    var helpText: String {
        "\(keys.joined(separator: ", ")): \(helpTextMessage)"
    }

    var keys: Set<String> {
        switch self {
        case .help: ["--help", "-h"]
        case .input: ["--input", "-i"]
        case .output: ["--output", "-o"]
        }
    }

    private var helpTextMessage: String {
        switch self {
        case .help: ""
        case .input: ""
        case .output: ""
        }
    }
}

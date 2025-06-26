// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

/// Service for managing files.
protocol FileService: Sendable {
    func contentsOfDirectory(atPath path: String) async throws -> [String]
}

/// Wrapper of `FileManager`.
actor DefaultFileService: FileService, Sendable {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: path)
    }
}

/// Stub implementation of `FileService`.
final class StubFileService: FileService {
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        ["/path/1", "/path/2", "/path/3"]
    }
}

// MARK: - Flag

extension Argument {
    fileprivate enum Flag {
        case help
        case input
        case output
    }
}

extension Argument.Flag: CaseIterable {}

extension Argument.Flag: CustomStringConvertible {
    var description: String {
        keys.joined(separator: ", ")
    }
}

extension Argument.Flag {
    var keys: Set<String> {
        switch self {
        case .help: ["--help", "-h"]
        case .input: ["--input", "-i"]
        case .output: ["--output", "-o"]
        }
    }

    init?(rawValue: String) {
        guard let flag = Argument.Flag.allCases.first(where: { $0.keys.contains(rawValue) }) else {
            return nil
        }

        self = flag
    }
}

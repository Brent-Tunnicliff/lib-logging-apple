// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

@Model
final class LogEntityV1: Equatable, Identifiable {
    private(set) var device: Device
    @Attribute(.unique)
    private(set) var id: UUID
    private(set) var level: LogLevel
    private(set) var message: String
    private(set) var packageName: String
    private(set) var tag: Tag
    private(set) var timestampCreated: Date
    private(set) var error: Error?

    /// Stores the rawValue of `level` so can be used for filtering.
    private(set) var levelRawValue: String

    init(
        device: Device,
        id: UUID = UUID(),
        level: LogLevel,
        message: String,
        packageName: String,
        tag: Tag,
        timestampCreated: Date,
        error: Error?
    ) {
        self.device = device
        self.id = id
        self.level = level
        self.levelRawValue = level.rawValue
        self.message = message
        self.packageName = packageName
        self.tag = tag
        self.timestampCreated = timestampCreated
        self.error = error
    }
}

// MARK: - Nested Types

extension LogEntityV1 {
    struct Error: Codable, Equatable {
        let type: String
        let message: String
    }

    struct Device: Codable, Equatable {
        let identifierForVendor: UUID?
        let model: String?
        let systemName: String?
        let systemVersion: String?
        let userInterfaceIdiom: UserInterfaceIdiom
    }

    enum LogLevel: String, Codable, Equatable, CaseIterable {
        case debug
        case info
        case error
        case critical
    }

    struct Tag: Codable, Equatable {
        let file: String
        let function: String
        let line: UInt
    }

    enum UserInterfaceIdiom: String, Codable, Equatable, CaseIterable {
        case carPlay
        case mac
        case pad
        case phone
        case tv
        case unspecified
        case vision
        case watch
    }
}

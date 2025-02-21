// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import SwiftData

enum LogEntitySchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [
        LogEntitySchemaV1.LogEntity.self
    ]

    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }
}

extension LogEntitySchemaV1 {
    @Model
    final class LogEntity: Equatable, Identifiable {
        var device: Device
        @Attribute(.unique)
        var id: UUID
        var level: LogLevel
        var message: String
        var packageName: String
        var tag: Tag
        var timestampCreated: Date
        var error: Error?

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
            self.message = message
            self.packageName = packageName
            self.tag = tag
            self.timestampCreated = timestampCreated
            self.error = error
        }
    }
}

// MARK: - Nested Types

extension LogEntitySchemaV1.LogEntity {
    struct Error: Codable, Equatable {
        let type: String
        let message: String
    }

    struct Device: Codable, Equatable {
        public let identifierForVendor: UUID?
        public let model: String?
        public let systemName: String?
        public let systemVersion: String?
        public let userInterfaceIdiom: UserInterfaceIdiom
    }

    enum LogLevel: Codable, Equatable {
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

    enum UserInterfaceIdiom: Codable, Equatable {
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

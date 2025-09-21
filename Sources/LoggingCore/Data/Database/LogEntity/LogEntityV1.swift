// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
package import SwiftData

@Model
package final class LogEntityV1: Equatable, Identifiable {
    package private(set) var device: Device
    @Attribute(.unique)
    package private(set) var id: UUID
    package private(set) var level: LogLevel
    package private(set) var message: String
    package private(set) var packageName: String
    package private(set) var tag: Tag
    package private(set) var timestampCreated: Date
    package private(set) var error: Error?

    package init(
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

// MARK: - Nested Types

extension LogEntityV1 {
    package struct Error: Codable, Equatable {
        package let type: String
        package let message: String
        package let localizedDescription: String

        package init(type: String, message: String, localizedDescription: String) {
            self.type = type
            self.message = message
            self.localizedDescription = localizedDescription
        }
    }

    package struct Device: Codable, Equatable {
        package let identifierForVendor: UUID?
        package let model: String?
        package let systemName: String?
        package let systemVersion: String?
        package let userInterfaceIdiom: UserInterfaceIdiom

        package init(
            identifierForVendor: UUID?,
            model: String?,
            systemName: String?,
            systemVersion: String?,
            userInterfaceIdiom: UserInterfaceIdiom
        ) {
            self.identifierForVendor = identifierForVendor
            self.model = model
            self.systemName = systemName
            self.systemVersion = systemVersion
            self.userInterfaceIdiom = userInterfaceIdiom
        }
    }

    package enum LogLevel: String, Codable, Equatable, CaseIterable {
        case debug
        case info
        case error
        case critical
    }

    package struct Tag: Codable, Equatable {
        package let file: String
        package let function: String
        package let line: UInt

        package init(file: String, function: String, line: UInt) {
            self.file = file
            self.function = function
            self.line = line
        }
    }

    package enum UserInterfaceIdiom: String, Codable, Equatable, CaseIterable {
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

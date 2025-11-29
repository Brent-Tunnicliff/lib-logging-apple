// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation
package import SwiftData
import Synchronization

// MARK: - LogEntityV1

@Model
package final class LogEntityV1 {
    package private(set) var device: Device
    @Attribute(.unique)
    package private(set) var id: UUID
    package private(set) var level: LogLevel
    package private(set) var message: String
    package private(set) var packageName: String
    package private(set) var tag: Tag
    package private(set) var timestampCreated: Date
    package private(set) var error: Error?
    package private(set) var thread: String

    /// Base value of ``error`` that can be used in Predicates.
    ///
    /// For some reason I am getting runtime errors when trying to use `error`, so this is a hack to just story the base string.
    private(set) var _errorRawValue: String

    /// Base value of ``id`` that can be used in Predicates.
    private(set) var _idRawValue: String

    /// Base value of ``level`` that can be used in Predicates.
    private(set) var _levelRawValue: LogLevel.RawValue

    package init(
        device: Device,
        id: UUID = UUID(),
        level: LogLevel,
        message: String,
        packageName: String,
        tag: Tag,
        timestampCreated: Date,
        error: Error?,
        thread: String
    ) {
        self.device = device
        self.id = id
        self.level = level
        self.message = message
        self.packageName = packageName
        self.tag = tag
        self.timestampCreated = timestampCreated
        self.error = error
        self.thread = thread
        let errorRawValue = error.map {
            [
                $0.type,
                $0.message,
                $0.localizedDescription,
            ].joined(separator: "_")
        }
        self._errorRawValue = errorRawValue ?? ""
        self._idRawValue = id.uuidString
        self._levelRawValue = level.rawValue
    }
}

// MARK: Extensions

extension LogEntityV1: Equatable {}
extension LogEntityV1: Identifiable {}

extension LogEntityV1: CustomDebugStringConvertible {
    package var debugDescription: String {
        let properties: [String] = [
            "\"device\":\(device.debugDescription)",
            "\"id\":\"\(id.uuidString)\"",
            "\"level\":\"\(level.rawValue)\"",
            "\"message\":\"\(message)\"",
            "\"packageName\":\"\(packageName)\"",
            "\"tag\":\(tag.debugDescription)",
            "\"timestampCreated\":\"\(timestampCreated.ISO8601Format())\"",
            error.map { "\"error\":\($0.debugDescription)" },
            "\"thread\":\"\(thread)\"",
        ].compactMap { $0 }
        return "{" + properties.joined(separator: ",") + "}"
    }
}

// MARK: - Error

extension LogEntityV1 {
    package struct Error {
        package let type: String
        package let message: String
        package let localizedDescription: String

        package init(type: String, message: String, localizedDescription: String) {
            self.type = type
            self.message = message
            self.localizedDescription = localizedDescription
        }
    }
}

// MARK: Extensions

extension LogEntityV1.Error: Codable {}
extension LogEntityV1.Error: Equatable {}

extension LogEntityV1.Error: CustomDebugStringConvertible {
    package var debugDescription: String {
        let properties: [String] = [
            "\"type\":\"\(type)\"",
            "\"message\":\"\(message)\"",
            "\"localizedDescription\":\"\(localizedDescription)\"",
        ]
        return "{" + properties.joined(separator: ",") + "}"
    }
}

// MARK: - Device

extension LogEntityV1 {
    package struct Device {
        package let identifierForVendor: UUID?
        package let model: String?
        package let systemName: String?
        package let systemVersion: String?
        package let userInterfaceIdiom: UserInterfaceIdiom

        /// Base value of ``identifierForVendor`` that can be used in Predicates.
        let _identifierForVendorRawValue: String?

        /// Base value of ``userInterfaceIdiom`` that can be used in Predicates.
        let _userInterfaceIdiomRawValue: UserInterfaceIdiom.RawValue

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
            self._identifierForVendorRawValue = identifierForVendor?.uuidString
            self._userInterfaceIdiomRawValue = userInterfaceIdiom.rawValue
        }
    }
}

// MARK: Extensions

extension LogEntityV1.Device: Codable {}
extension LogEntityV1.Device: Equatable {}

extension LogEntityV1.Device: CustomDebugStringConvertible {
    package var debugDescription: String {
        let properties: [String] = [
            identifierForVendor.map { "\"identifierForVendor\":\"\($0.uuidString)\"" },
            model.map { "\"model\":\"\($0)\"" },
            systemName.map { "\"systemName\":\"\($0)\"" },
            systemVersion.map { "\"systemVersion\":\"\($0)\"" },
            "\"userInterfaceIdiom\":\"\(userInterfaceIdiom.rawValue)\"",
        ].compactMap { $0 }
        return "{" + properties.joined(separator: ",") + "}"
    }
}

// MARK: - LogLevel

extension LogEntityV1 {
    package enum LogLevel: String {
        case debug
        case info
        case error
        case critical
    }
}

// MARK: Extensions

extension LogEntityV1.LogLevel: CaseIterable {}
extension LogEntityV1.LogLevel: Codable {}
extension LogEntityV1.LogLevel: Equatable {}

// MARK: - Tag

extension LogEntityV1 {
    package struct Tag {
        package let file: String
        package let function: String
        package let line: UInt

        package init(file: String, function: String, line: UInt) {
            self.file = file
            self.function = function
            self.line = line
        }
    }
}

// MARK: Extensions

extension LogEntityV1.Tag: Codable {}
extension LogEntityV1.Tag: Equatable {}

extension LogEntityV1.Tag: CustomDebugStringConvertible {
    package var debugDescription: String {
        let properties: [String] = [
            "\"file\":\"\(file)\"",
            "\"function\":\"\(function)\"",
            "\"line\":\(line)",
        ]
        return "{" + properties.joined(separator: ",") + "}"
    }
}

// MARK: - UserInterfaceIdiom

extension LogEntityV1 {
    package enum UserInterfaceIdiom: String {
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

// MARK: Extensions

extension LogEntityV1.UserInterfaceIdiom: CaseIterable {}
extension LogEntityV1.UserInterfaceIdiom: Codable {}
extension LogEntityV1.UserInterfaceIdiom: Equatable {}

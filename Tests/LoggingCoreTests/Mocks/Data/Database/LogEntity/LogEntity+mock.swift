// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore

extension LogEntity {
    static func mock(
        device: Device = .mock(),
        id: UUID = UUID(),
        level: LogLevel = .debug,
        message: String = "Mock log",
        packageName: String = "Logging",
        tag: LogEntity.Tag = .mock(),
        timestampCreated: Date = Date(),
        error: Error? = nil
    ) -> LogEntity {
        LogEntity(
            device: device,
            id: id,
            level: level,
            message: message,
            packageName: packageName,
            tag: tag,
            timestampCreated: timestampCreated,
            error: error
        )
    }
}

extension LogEntity.Device {
    static func mock(
        identifierForVendor: UUID? = UUID(),
        model: String? = "iPhone",
        systemName: String? = "iOS",
        systemVersion: String? = "18.3",
        userInterfaceIdiom: LogEntity.UserInterfaceIdiom = .phone
    ) -> LogEntity.Device {
        LogEntity.Device(
            identifierForVendor: identifierForVendor,
            model: model,
            systemName: systemName,
            systemVersion: systemVersion,
            userInterfaceIdiom: userInterfaceIdiom
        )
    }
}

extension LogEntity.Error {
    static func mock(
        type: String = "Mock",
        message: String = "Something went wrong (not really)",
        localizedDescription: String = "Something went wrong in locale"
    ) -> LogEntity.Error {
        LogEntity.Error(
            type: type,
            message: message,
            localizedDescription: localizedDescription
        )
    }
}

extension LogEntity.Tag {
    static func mock(
        file: String = "Logging/LogEntity.swift",
        function: String = "mock(file:function:line:)",
        line: UInt = 76
    ) -> LogEntity.Tag {
        LogEntity.Tag(
            file: file,
            function: function,
            line: line
        )
    }
}

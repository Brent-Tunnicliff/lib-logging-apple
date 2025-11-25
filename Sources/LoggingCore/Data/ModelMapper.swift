// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

protocol ModelMapper: Sendable {
    func toEntity(device: Device) -> LogEntity.Device
    func toEntity(error: any Error) -> LogEntity.Error
    func toEntity(logLevel: LogLevel) -> LogEntity.LogLevel
    func toEntity(logTag: LogTag) -> LogEntity.Tag
    func toEntity(userInterfaceIdiom: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom
    func toExportContent(logEntity: LogEntity) -> String
}

// MARK: - DefaultModelMapper

final class DefaultModelMapper: ModelMapper {
    func toEntity(device: Device) -> LogEntity.Device {
        LogEntity.Device(
            identifierForVendor: device.identifierForVendor,
            model: device.model,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            userInterfaceIdiom: toEntity(userInterfaceIdiom: device.userInterfaceIdiom)
        )
    }

    func toEntity(error: any Error) -> LogEntity.Error {
        LogEntity.Error(
            type: "\(error.self)",
            message: "\(error)",
            localizedDescription: error.localizedDescription
        )
    }

    func toEntity(logLevel: LogLevel) -> LogEntity.LogLevel {
        switch logLevel {
        case .debug: .debug
        case .info: .info
        case .error: .error
        case .critical: .critical
        }
    }

    func toEntity(logTag: LogTag) -> LogEntity.Tag {
        LogEntity.Tag(
            file: logTag.file.description,
            function: logTag.function.description,
            line: logTag.line
        )
    }

    func toEntity(userInterfaceIdiom: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom {
        switch userInterfaceIdiom.rawValue {
        case .carPlay: .carPlay
        case .mac: .mac
        case .pad: .pad
        case .phone: .phone
        case .tv: .tv
        case .unspecified: .unspecified
        case .vision: .vision
        case .watch: .watch
        }
    }

    func toExportContent(logEntity: LogEntity) -> String {
        logEntity.exportContent()
    }
}

// MARK: - Export Helpers

private protocol ExportContent {
    func exportContent() -> String
}

extension LogEntity: ExportContent {
    /// Returns the log in a string format for writing to the export file.
    fileprivate func exportContent() -> String {
        """
        \(timestampCreated.ISO8601Format()) \
        [\(thread)] \
        [\(packageName)] \
        [\(level.exportContent())] \
        [\(tag.exportContent())] \
        \(exportBody())\n
        """
    }

    private func exportBody() -> String {
        [
            message,
            error.map { $0.exportContent() },
            device.exportContent(),
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}

extension LogEntity.Device: ExportContent {
    fileprivate func exportContent() -> String {
        "device: \(exportDetails)"
    }

    private var exportDetails: String {
        [
            identifierForVendor?.uuidString,
            model,
            systemName,
            systemVersion,
            "(\(userInterfaceIdiom.exportContent()))",
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
}

extension LogEntity.Error: ExportContent {
    fileprivate func exportContent() -> String {
        "error: \(type) - \(message) (\(localizedDescription))"
    }
}

extension LogEntity.LogLevel: ExportContent {
    fileprivate func exportContent() -> String {
        // Padding the string so they all take up the same space as the longest.
        rawValue.padding(toLength: Self.maxLength, withPad: " ", startingAt: 0)
    }

    private static let maxLength: Int = {
        LogEntity.LogLevel.allCases
            .map(\.rawValue.count)
            .max() ?? 0
    }()
}

extension LogEntity.Tag: ExportContent {
    fileprivate func exportContent() -> String {
        "\(file):\(function):\(line)"
    }
}

extension LogEntity.UserInterfaceIdiom: ExportContent {
    fileprivate func exportContent() -> String {
        rawValue
    }
}

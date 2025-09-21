// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Synchronization

@testable import LoggingCore

final class MockModelMapper: ModelMapper {
    // MARK: - toEntity(device:)

    typealias ToEntityDeviceResponse = @Sendable (Device) -> LogEntity.Device
    private let toEntityDeviceResponseMutex = Mutex<ToEntityDeviceResponse>({ _ in .mock() })
    var toEntityDeviceResponse: ToEntityDeviceResponse {
        get { toEntityDeviceResponseMutex.withLock { $0 } }
        set { toEntityDeviceResponseMutex.withLock { $0 = newValue } }
    }
    func toEntity(device: Device) -> LogEntity.Device {
        toEntityDeviceResponse(device)
    }

    // MARK: - toEntity(error:)

    typealias ToEntityErrorResponse = @Sendable (any Error) -> LogEntity.Error
    private let toEntityErrorResponseMutex = Mutex<ToEntityErrorResponse>({ _ in .mock() })
    var toEntityErrorResponse: ToEntityErrorResponse {
        get { toEntityErrorResponseMutex.withLock { $0 } }
        set { toEntityErrorResponseMutex.withLock { $0 = newValue } }
    }
    func toEntity(error: any Error) -> LogEntity.Error {
        toEntityErrorResponse(error)
    }

    // MARK: - toEntity(logLevel:)

    typealias ToEntityLogLevelResponse = @Sendable (LogLevel) -> LogEntity.LogLevel
    private let toEntityLogLevelResponseMutex = Mutex<ToEntityLogLevelResponse>({ _ in .info })
    var toEntityLogLevelResponse: ToEntityLogLevelResponse {
        get { toEntityLogLevelResponseMutex.withLock { $0 } }
        set { toEntityLogLevelResponseMutex.withLock { $0 = newValue } }
    }
    func toEntity(logLevel: LogLevel) -> LogEntity.LogLevel {
        toEntityLogLevelResponse(logLevel)
    }

    // MARK: - toEntity(logTag:)

    typealias ToEntityLogTagResponse = @Sendable (LogTag) -> LogEntity.Tag
    private let toEntityLogTagResponseMutex = Mutex<ToEntityLogTagResponse>({ _ in .mock() })
    var toEntityLogTagResponse: ToEntityLogTagResponse {
        get { toEntityLogTagResponseMutex.withLock { $0 } }
        set { toEntityLogTagResponseMutex.withLock { $0 = newValue } }
    }
    func toEntity(logTag: LogTag) -> LogEntity.Tag {
        toEntityLogTagResponse(logTag)
    }

    // MARK: - toEntity(userInterfaceIdiom:)

    typealias ToEntityUserInterfaceIdiomResponse = @Sendable (Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom
    private let toEntityUserInterfaceIdiomResponseMutex = Mutex<ToEntityUserInterfaceIdiomResponse>({ _ in .phone })
    var toEntityUserInterfaceIdiomResponse: ToEntityUserInterfaceIdiomResponse {
        get { toEntityUserInterfaceIdiomResponseMutex.withLock { $0 } }
        set { toEntityUserInterfaceIdiomResponseMutex.withLock { $0 = newValue } }
    }
    func toEntity(userInterfaceIdiom: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom {
        toEntityUserInterfaceIdiomResponse(userInterfaceIdiom)
    }

    // MARK: - toExportContent(logEntity:)

    typealias ToExportContentLogEntityResponse = @Sendable (LogEntity) -> String
    private let toExportContentLogEntityResponseMutex = Mutex<ToExportContentLogEntityResponse>({ _ in "export" })
    var toExportContentLogEntityResponse: ToExportContentLogEntityResponse {
        get { toExportContentLogEntityResponseMutex.withLock { $0 } }
        set { toExportContentLogEntityResponseMutex.withLock { $0 = newValue } }
    }
    func toExportContent(logEntity: LogEntity) -> String {
        toExportContentLogEntityResponse(logEntity)
    }
}

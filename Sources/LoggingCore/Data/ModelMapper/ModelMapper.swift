// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

protocol ModelMapper: Sendable {
    func toEntity(device: Device) -> LogEntity.Device
    func toEntity(error: any Error) -> LogEntity.Error
    func toEntity(logLevel: LogLevel) -> LogEntity.LogLevel
    func toEntity(logTag: LogTag) -> LogEntity.Tag
    func toEntity(userInterfaceIdiom: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom
    func toExportContent(logEntity: LogEntity) -> String
}

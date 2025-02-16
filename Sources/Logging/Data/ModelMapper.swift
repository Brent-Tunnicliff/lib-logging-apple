// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

protocol ModelMapper {
    func toEntity(_ model: Device) -> LogEntity.Device
    func toEntity(_ model: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom
    func toEntity(_ model: any Error) -> LogEntity.Error
    func toEntity(_ model: LogLevel) -> LogEntity.LogLevel
    func toEntity(_ model: LogTag) -> LogEntity.Tag
}

class DefaultModelMapper: ModelMapper {
    func toEntity(_ model: Device) -> LogEntity.Device {
        LogEntity.Device(
            identifierForVendor: model.identifierForVendor,
            model: model.model,
            systemName: model.systemName,
            systemVersion: model.systemVersion,
            userInterfaceIdiom: toEntity(model.userInterfaceIdiom)
        )
    }

    func toEntity(_ model: Device.UserInterfaceIdiom) -> LogEntity.UserInterfaceIdiom {
        switch model.rawValue {
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

    func toEntity(_ model: any Error) -> LogEntity.Error {
        LogEntity.Error(
            type: "\(model.self)",
            message: model.localizedDescription
        )
    }

    func toEntity(_ model: LogLevel) -> LogEntity.LogLevel {
        switch model.wrapped {
        case .debug: .debug
        case .info: .info
        case .error: .error
        case .critical: .critical
        }
    }

    func toEntity(_ model: LogTag) -> LogEntity.Tag {
        LogEntity.Tag(
            file: model.file.description,
            function: model.function.description,
            line: model.line
        )
    }
}

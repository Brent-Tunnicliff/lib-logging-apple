// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import Testing

@testable import LoggingCore

struct ModelMapperTests {
    private let modelMapper: any ModelMapper = DefaultModelMapper()

    private let expectedLogLevelMappings: [LogLevel: LogEntity.LogLevel] = [
        .debug: .debug,
        .info: .info,
        .error: .error,
        .critical: .critical,
    ]

    private let expectedUserInterfaceIdiomMappings: [Device.UserInterfaceIdiom: LogEntity.UserInterfaceIdiom] = [
        .carPlay: .carPlay,
        .mac: .mac,
        .pad: .pad,
        .phone: .phone,
        .tv: .tv,
        .unspecified: .unspecified,
        .vision: .vision,
        .watch: .watch,
    ]

    @Test(arguments: Device.UserInterfaceIdiom.allCases)
    func toEntityDevice(userInterfaceIdiom: Device.UserInterfaceIdiom) {
        let device = Device.mock(userInterfaceIdiom: userInterfaceIdiom)
        let result = modelMapper.toEntity(device: device)
        #expect(result.identifierForVendor == device.identifierForVendor)
        #expect(result.model == device.model)
        #expect(result.systemName == device.systemName)
        #expect(result.systemVersion == device.systemVersion)
        #expect(result.userInterfaceIdiom == expectedUserInterfaceIdiomMappings[userInterfaceIdiom])
    }

    @Test(arguments: Device.UserInterfaceIdiom.allCases)
    func toEntityDeviceUserInterfaceIdiom(userInterfaceIdiom: Device.UserInterfaceIdiom) {
        let result = modelMapper.toEntity(userInterfaceIdiom: userInterfaceIdiom)
        #expect(result == expectedUserInterfaceIdiomMappings[userInterfaceIdiom])
    }

    @Test
    func toEntityError() {
        let error = MockError()
        let result = modelMapper.toEntity(error: error)
        #expect(result.type == "MockError()")
        #expect(result.message == "MockError()")
        #expect(
            result.localizedDescription == "The operation couldn’t be completed. (LoggingCoreTests.MockError error 1.)"
        )
    }

    @Test(arguments: LogLevel.allCases)
    func toEntityLogLevel(logLevel: LogLevel) {
        let result = modelMapper.toEntity(logLevel: logLevel)
        #expect(result == expectedLogLevelMappings[logLevel])
    }

    @Test
    func toEntityLogTag() {
        let logTag = LogTag(
            file: "ModelMapperTests-file",
            function: "ModelMapperTests-function",
            line: 42
        )

        let result = modelMapper.toEntity(logTag: logTag)
        #expect(result.file == "ModelMapperTests-file")
        #expect(result.function == "ModelMapperTests-function")
        #expect(result.line == 42)
    }

    enum ToExportContentArgument: CaseIterable {
        case withEverything
        case withoutDeviceIdentifierForVendor
        case withoutDeviceModel
        case withoutDeviceSystemName
        case withoutDeviceSystemVersion
        case withoutError

        var logEntry: LogEntity {
            get throws {
                try LogEntity(
                    device: LogEntity.Device(
                        identifierForVendor: deviceIdentifierForVendor,
                        model: deviceModel,
                        systemName: deviceSystemName,
                        systemVersion: deviceSystemVersion,
                        userInterfaceIdiom: .phone
                    ),
                    id: .forced(uuidString: "00000000-0000-0000-0000-000000000001"),
                    level: .info,
                    message: "This is a log",
                    packageName: "LoggingCoreTests",
                    tag: LogEntity.Tag(
                        file: "LoggingCoreTests/ModelMapperTests.swift",
                        function: "toExportContentWithError()",
                        line: 10
                    ),
                    timestampCreated: timestampCreated,
                    error: error,
                    thread: "Main"
                )
            }
        }

        var expectedResult: String {
            switch self {
            case .withEverything:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, error: MockError - An error happened (Oh no!), device: 00000000-0000-0000-0000-000000000002 iPhone17,3 iOS 26 (phone)\n"
            case .withoutDeviceIdentifierForVendor:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, error: MockError - An error happened (Oh no!), device: iPhone17,3 iOS 26 (phone)\n"
            case .withoutDeviceModel:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, error: MockError - An error happened (Oh no!), device: 00000000-0000-0000-0000-000000000002 iOS 26 (phone)\n"
            case .withoutDeviceSystemName:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, error: MockError - An error happened (Oh no!), device: 00000000-0000-0000-0000-000000000002 iPhone17,3 26 (phone)\n"
            case .withoutDeviceSystemVersion:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, error: MockError - An error happened (Oh no!), device: 00000000-0000-0000-0000-000000000002 iPhone17,3 iOS (phone)\n"
            case .withoutError:
                "2025-09-25T12:27:35Z [Main] [LoggingCoreTests] [info    ] [LoggingCoreTests/ModelMapperTests.swift:toExportContentWithError():10] This is a log, device: 00000000-0000-0000-0000-000000000002 iPhone17,3 iOS 26 (phone)\n"
            }
        }

        private var deviceIdentifierForVendor: UUID? {
            get throws {
                switch self {
                case .withoutDeviceIdentifierForVendor: nil
                default: try .forced(uuidString: "00000000-0000-0000-0000-000000000002")
                }
            }
        }

        private var deviceModel: String? {
            switch self {
            case .withoutDeviceModel: nil
            default: "iPhone17,3"
            }
        }

        private var deviceSystemName: String? {
            switch self {
            case .withoutDeviceSystemName: nil
            default: "iOS"
            }
        }

        private var deviceSystemVersion: String? {
            switch self {
            case .withoutDeviceSystemVersion: nil
            default: "26"
            }
        }

        private var error: LogEntity.Error? {
            switch self {
            case .withoutError: nil
            default:
                LogEntity.Error(
                    type: "MockError",
                    message: "An error happened",
                    localizedDescription: "Oh no!"
                )
            }
        }

        private var timestampCreated: Date {
            let dateString = "2025-09-25T12:27:35Z"
            guard let date = try? Date.ISO8601FormatStyle().parse(dateString) else {
                preconditionFailure("Unexpected nil formatting date '\(dateString)'")
            }

            return date
        }
    }

    @Test(arguments: ToExportContentArgument.allCases)
    func toExportContent(_ argument: ToExportContentArgument) throws {
        let logEntry = try argument.logEntry
        let result = modelMapper.toExportContent(logEntity: logEntry)
        #expect(result == argument.expectedResult)
    }
}

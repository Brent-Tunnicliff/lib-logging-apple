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
}

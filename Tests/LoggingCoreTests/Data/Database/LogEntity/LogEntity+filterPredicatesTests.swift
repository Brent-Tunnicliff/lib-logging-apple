// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import SwiftData
import Testing

@MainActor
@Suite("LogEntity+filterPredicatesTests")
struct LogEntityFilterPredicatesTests {
    // We don't really need to use this modelContainer in the tests,
    // but have noticed occasional crashes if creating models without these getting initialised first.
    private let modelContext = ModelContext(.emptyInMemoryOnly())

    @Test(
        arguments: [
            LogEntity.LogLevel.allCases,
            [.info, .error, .critical],
            [.error, .critical],
            [.critical, .info],
            [.debug, .error],
            [.debug],
            [.info],
            [.error],
            [.critical],
        ] as [[LogEntity.LogLevel]]
    )
    func filterByLevelPredicate(_ logLevelsToShow: [LogEntity.LogLevel]) throws {
        let logEntities: [LogEntity] = LogEntity.LogLevel.allCases.map {
            .mock(level: $0)
        }

        let expectedResults = logEntities.filter {
            logLevelsToShow.contains($0.level)
        }

        let predicate = LogEntity.filterByLevelPredicate(logLevelsToShow)
        let results = try logEntities.filter(predicate)

        #expect(results.count == expectedResults.count)
        for result in results {
            #expect(
                expectedResults.contains(where: { $0.id == result.id }),
                "Result contains unexpected log: \(result.id)"
            )
        }
    }

    @Test(arguments: [
        // Device
        SearchPredicateArgument(input: "20000000-0000-0000-0000-000000000000", expectedLogs: []),
        SearchPredicateArgument(input: "20000000-0000-0000-0000-000000000001", expectedLogs: [1]),
        SearchPredicateArgument(input: "20000000-0000-0000-0000-000000000005", expectedLogs: [5]),
        SearchPredicateArgument(input: "device_model_2", expectedLogs: [2]),
        SearchPredicateArgument(input: "model_3", expectedLogs: [3]),
        SearchPredicateArgument(input: "device_systemName_4", expectedLogs: [4]),
        SearchPredicateArgument(input: "systemName_4", expectedLogs: [4]),
        SearchPredicateArgument(input: "systemName", expectedLogs: [1, 2, 3, 4, 5, 6, 7]),

        // Error
        SearchPredicateArgument(input: "error_type_3", expectedLogs: [3]),
        SearchPredicateArgument(input: "type", expectedLogs: [1, 2, 3, 4, 5, 6, 7]),
        SearchPredicateArgument(input: "error_message_5", expectedLogs: [5]),
        SearchPredicateArgument(input: "error_localizedDescription_7", expectedLogs: [7]),

        // Log
        SearchPredicateArgument(input: "10000000-0000-0000-0000-000000000005", expectedLogs: [5]),
        SearchPredicateArgument(input: "message_5", expectedLogs: [5]),
        SearchPredicateArgument(input: "packageName_5", expectedLogs: [5]),
        SearchPredicateArgument(input: "thread_5", expectedLogs: [5]),

        // Tag
        SearchPredicateArgument(input: "tag_file_0", expectedLogs: [0]),
        SearchPredicateArgument(input: "tag_function_1", expectedLogs: [1]),
        SearchPredicateArgument(input: "tag_function", expectedLogs: [0, 1, 2, 3, 4, 5, 6, 7]),
        SearchPredicateArgument(input: "33", expectedLogs: [3]),

        // UserInterfaceIdiom
        SearchPredicateArgument(input: "carPlay", expectedLogs: [0]),
        SearchPredicateArgument(input: "car", expectedLogs: [0]),
        SearchPredicateArgument(input: "mac", expectedLogs: [1]),
        SearchPredicateArgument(input: "pad", expectedLogs: [2]),
        SearchPredicateArgument(input: "phone", expectedLogs: [3]),
        SearchPredicateArgument(input: "tv", expectedLogs: [4]),
        SearchPredicateArgument(input: "unspecified", expectedLogs: [5]),
        SearchPredicateArgument(input: "specifi", expectedLogs: [5]),
        SearchPredicateArgument(input: "vision", expectedLogs: [6]),
        SearchPredicateArgument(input: "watch", expectedLogs: [7]),
        SearchPredicateArgument(input: "tch", expectedLogs: [7]),

        // Empty results
        SearchPredicateArgument(input: "", expectedLogs: []),
        SearchPredicateArgument(input: "1234", expectedLogs: []),
        SearchPredicateArgument(input: "nil", expectedLogs: []),

        // Misc
        SearchPredicateArgument(input: "0", expectedLogs: [0, 1, 2, 3, 4, 5, 6, 7]),
        SearchPredicateArgument(input: "1", expectedLogs: [0, 1, 2, 3, 4, 5, 6, 7]),
        SearchPredicateArgument(input: "2", expectedLogs: [1, 2, 3, 4, 5, 6, 7]),
        SearchPredicateArgument(input: "3", expectedLogs: [3]),
        SearchPredicateArgument(input: "4", expectedLogs: [4]),
        SearchPredicateArgument(input: "5", expectedLogs: [5]),
        SearchPredicateArgument(input: "6", expectedLogs: [6]),
        SearchPredicateArgument(input: "7", expectedLogs: [7]),
    ])
    func searchPredicate(_ argument: SearchPredicateArgument) throws {
        let logEntities = Self.searchPredicateLogEntities()
        let expectedResults = logEntities.filter {
            argument.expectedLogs.contains($0.key)
        }.map(\.value)

        let predicate = LogEntity.searchPredicate(argument.input)
        let results = try logEntities.values.filter(predicate)

        #expect(results.count == expectedResults.count)
        for result in results {
            #expect(
                expectedResults.contains(where: { $0.id == result.id }),
                "Result of '\(argument.input)' contains unexpected log: \(result.id)"
            )
        }

        let lowerCasedInputPredicate = LogEntity.searchPredicate(argument.input.lowercased())
        let lowerCasedInputResults = try logEntities.values.filter(lowerCasedInputPredicate)
        #expect(lowerCasedInputResults == results)

        let upperCasedInputPredicate = LogEntity.searchPredicate(argument.input.lowercased())
        let upperCasedInputResults = try logEntities.values.filter(upperCasedInputPredicate)
        #expect(upperCasedInputResults == results)
    }

    // MARK: - Helpers - searchPredicate

    struct SearchPredicateArgument: Sendable {
        let input: String

        // Each log is generated with a unique int as an identifier.
        let expectedLogs: [Int]
    }

    fileprivate static func searchPredicateLogEntities() -> [Int: LogEntity] {
        let userInterfaceIdioms = LogEntity.UserInterfaceIdiom.allCases
        let idFormatter = NumberFormatter()
        idFormatter.minimumIntegerDigits = 12

        let entities = userInterfaceIdioms.enumerated().reduce(into: [Int: LogEntity]()) { partialResult, value in
            let (number, userInterfaceIdiom) = value
            guard let idComponent = idFormatter.string(from: NSNumber(value: number)) else {
                preconditionFailure("Failed to generate expected log id string for \(number)")
            }

            // Defining all UUID values here to make sure they are unique on quick look.
            let idString = "10000000-0000-0000-0000-\(idComponent)"
            let deviceIdentifierForVendorString = "20000000-0000-0000-0000-\(idComponent)"

            let deviceIdentifierForVendor: UUID?
            let deviceModel: String?
            let deviceSystemName: String?
            let deviceSystemVersion: String?
            let error: LogEntityV1.Error?
            // Making the number `0` contain all the `nil` values for simplicity.
            if number == 0 {
                deviceIdentifierForVendor = nil
                deviceModel = nil
                deviceSystemName = nil
                deviceSystemVersion = nil
                error = nil
            } else {
                deviceIdentifierForVendor = .forced(uuidString: deviceIdentifierForVendorString)
                deviceModel = "device_model_\(number)"
                deviceSystemName = "device_systemName_\(number)"
                deviceSystemVersion = "device_systemVersion_\(number)"
                error = LogEntity.Error(
                    type: "error_type_\(number)",
                    message: "error_message_\(number)",
                    localizedDescription: "error_localizedDescription_\(number)"
                )
            }

            let device = LogEntity.Device(
                identifierForVendor: deviceIdentifierForVendor,
                model: deviceModel,
                systemName: deviceSystemName,
                systemVersion: deviceSystemVersion,
                userInterfaceIdiom: userInterfaceIdiom
            )

            let tag = LogEntity.Tag(
                file: "tag_file_\(number)",
                function: "tag_function_\(number)",
                line: UInt(number) * 11
            )

            let entity = LogEntity(
                device: device,
                id: .forced(uuidString: idString),
                // we don't search for level, so value does not matter.
                level: .debug,
                message: "message_\(number)",
                packageName: "packageName_\(number)",
                tag: tag,
                // we don't search for date, so value does not matter.
                timestampCreated: Date(),
                error: error,
                thread: "thread_\(number)"
            )

            partialResult[number] = entity
        }

        // Validate generated values

        precondition(entities.count == userInterfaceIdioms.count)

        // All `LogEntity.id` values are unique.
        let uniqueIds: Set<UUID> = Set(entities.values.map(\.id))
        precondition(uniqueIds.count == userInterfaceIdioms.count)

        // All `LogEntity.device.identifierForVendor` values are unique, but one will be nil so don't bother with it.
        let uniqueDeviceIdentifierForVendors: Set<UUID> = Set(entities.values.compactMap(\.device.identifierForVendor))
        precondition(uniqueDeviceIdentifierForVendors.count == userInterfaceIdioms.count - 1)

        // All UUID values are unique between `LogEntity.id` and `LogEntity.device.identifierForVendor`.
        let uniqueAllIds: Set<UUID> = uniqueIds.union(uniqueDeviceIdentifierForVendors)
        precondition(uniqueAllIds.count == uniqueIds.count + uniqueDeviceIdentifierForVendors.count)

        return entities
    }
}

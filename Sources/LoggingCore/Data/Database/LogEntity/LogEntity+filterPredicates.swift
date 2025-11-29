// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package import Foundation

extension LogEntity {
    /// Returns a Predicate for searching fields for the input value.
    ///
    /// Does not search log level as there is a different way to filter that.
    /// Does not search timestamp as that increases complexity significantly.
    package static func searchPredicate(_ value: String) -> Predicate<LogEntity> {
        let devicePredicate = CommonPredicate.device(value)
        let stringPredicate = CommonPredicate.string(value)
        let tagPredicate = CommonPredicate.tag(value)

        // The predicate is too complicated to do in one, so had to split to avoid compile error.
        let firstHalf = #Predicate<LogEntity> { log in
            devicePredicate.evaluate(log)
                || stringPredicate.evaluate(log._idRawValue)
                || stringPredicate.evaluate(log.message)
                || stringPredicate.evaluate(log.packageName)
        }

        let secondHalf = #Predicate<LogEntity> { log in
            tagPredicate.evaluate(log)
                || stringPredicate.evaluate(log._errorRawValue)
                || stringPredicate.evaluate(log.thread)
        }

        return #Predicate { log in
            firstHalf.evaluate(log)
                || secondHalf.evaluate(log)
        }
    }

    /// Returns a Predicate for filtering based on the input log levels..
    package static func filterByLevelPredicate(_ logLevelsToShow: [LogEntity.LogLevel]) -> Predicate<LogEntity> {
        let baseLevelValues = logLevelsToShow.map(\.rawValue)
        return #Predicate {
            baseLevelValues.contains($0._levelRawValue)
        }
    }
}

private enum CommonPredicate {
    static func device(_ value: String) -> Predicate<LogEntity> {
        let optionalStringPredicate = CommonPredicate.optionalString(value)
        let string = CommonPredicate.string(value)
        return #Predicate { log in
            optionalStringPredicate.evaluate(log.device._identifierForVendorRawValue)
                || optionalStringPredicate.evaluate(log.device.model)
                || optionalStringPredicate.evaluate(log.device.systemName)
                || optionalStringPredicate.evaluate(log.device.systemVersion)
                || string.evaluate(log.device._userInterfaceIdiomRawValue)
        }
    }

    static func optionalString(_ value: String) -> Predicate<String?> {
        #Predicate {
            $0?.localizedStandardContains(value) == true
        }
    }

    static func string(_ value: String) -> Predicate<String> {
        #Predicate {
            $0.localizedStandardContains(value)
        }
    }

    static func tag(_ value: String) -> Predicate<LogEntity> {
        let stringPredicate = CommonPredicate.string(value)
        return #Predicate { log in
            stringPredicate.evaluate(log.tag.file)
                || stringPredicate.evaluate(log.tag.function)
                || stringPredicate.evaluate(log.tag.line.description)
        }
    }
}

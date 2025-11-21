// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import RegexBuilder

extension Thread {
    package static var nameForLog: String {
        Thread.current.nameForLog
    }

    package var nameForLog: String {
        guard !isMainThread else {
            return "Main"
        }

        guard let number = extractNumber() else {
            return "????"
        }

        // If the number has 5 or more digits, then just return the whole number.
        // This will probably never happen?
        guard number < 10_000 else {
            return number.description
        }

        return number.formatted(.number.precision(.integerLength(4)).grouping(.never))
    }

    private func extractNumber() -> Int? {
        let numberReference = Reference<Substring>()
        let regex = Regex {
            One("number = ")
            Capture(as: numberReference) {
                OneOrMore(.digit)
            }
            One(", name")
        }
        let match = description.firstMatch(of: regex)
        guard let numberValue = match?[numberReference], let number = Int(numberValue) else {
            return nil
        }

        return number
    }
}

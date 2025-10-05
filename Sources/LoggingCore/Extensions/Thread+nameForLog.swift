// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import RegexBuilder

extension Thread {
    package static var nameForLog: String {
        let thread = Thread.current

        guard !thread.isMainThread else {
            return "Main"
        }

        guard let number = thread.extractNumber() else {
            return "????"
        }

        return String(format: "%04d", number)
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

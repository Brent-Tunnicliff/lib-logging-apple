// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

enum Flag {
    case help
    case output
}

extension Flag: CaseIterable {}

extension Flag: CustomStringConvertible {
    var description: String {
        keys.joined(separator: ", ")
    }
}

extension Flag {
    init?(rawValue: String) {
        guard let flag = Flag.allCases.first(where: { $0.keys.contains(rawValue) }) else {
            return nil
        }

        self = flag
    }
}

extension Flag {
    var helpText: String {
        "\(keys.joined(separator: ", ")): \(helpTextMessage)"
    }

    var keys: Set<String> {
        switch self {
        case .help: ["--help", "-h"]
        case .output: ["--output", "-o"]
        }
    }

    private var helpTextMessage: String {
        switch self {
        case .help: "Prints help information."
        case .output: "Declare the output location for the generated files. Expected to be a `Settings.bundle`."
        }
    }
}

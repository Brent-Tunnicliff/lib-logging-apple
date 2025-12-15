// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

@main
struct LoggingSettingsGenerator {
    private static let argumentService = DefaultArgumentService()

    static func main() async {
        do {
            switch try await argumentService.parseArgument() {
            case .help:
                print(argumentService.helpMessage)
            case let .output(url):
                try processFiles(output: url)
            }
        } catch {
            print(
                """
                Error: \(error)

                \(argumentService.helpMessage)
                """
            )
            exit(EXIT_FAILURE)
        }
    }

    // Simple process to copy the contents of the Logging Settings.bundle to the output.
    // Does not do any validation or editing of Root.plist to link to it.
    private static func processFiles(output: URL) throws {
        guard let settingsBundle = Bundle.module.url(forResource: "Settings", withExtension: "bundle") else {
            throw SettingsError.unableToFindSettingsBundle
        }

        var filesToCopy: Set<URL> = []

        let fileManager = FileManager.default
        let contentsOfSettings = try fileManager.contentsOfDirectory(
            at: settingsBundle,
            includingPropertiesForKeys: nil,
            options: .producesRelativePathURLs
        )

        for file in contentsOfSettings where !file.hasDirectoryPath {
            filesToCopy.insert(file)
        }

        for localisation in contentsOfSettings where localisation.pathExtension == "lproj" {
            let otherFiles = try fileManager.contentsOfDirectory(
                at: localisation,
                includingPropertiesForKeys: nil,
                options: .producesRelativePathURLs
            )

            for file in otherFiles {
                filesToCopy.insert(file)
            }
        }

        for file in filesToCopy {
            let destination = URL(fileURLWithPath: output.path())
                .appendingPathComponent(file.pathRelative(to: settingsBundle))

            if fileManager.fileExists(atPath: destination.path()) {
                print("Deleting '\(destination.absoluteString)'")
                try fileManager.removeItem(at: destination)
            }

            print("Copying '\(file.absoluteString)' to '\(destination.absoluteString)'")
            try fileManager.copyItem(at: file, to: destination)
        }
    }
}

extension URL {
    func pathRelative(to base: URL) -> String {
        String(absoluteString.trimmingPrefix(base.absoluteString))
    }
}

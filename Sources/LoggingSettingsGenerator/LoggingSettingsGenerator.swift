// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

@main
struct LoggingSettingsGenerator {
//    private static let fileService: any FileService = DefaultFileService()
    private static let fileService: any FileService = StubFileService()
    private static let argumentService = DefaultArgumentService(fileService: fileService)

    static func main() async {
        do {
            switch try await argumentService.parseArgument() {
            case .help:
                printHelpMessage()
            case let .files(values):
                processFiles(files: values)
            }
        } catch {
            print("Error: \(error)")
            printHelpMessage()
        }
    }

    private static func printHelpMessage() {
        print(argumentService.helpMessage)
    }

    private static func processFiles(files: [Argument.File]) {

    }
}

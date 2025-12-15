# lib-logging-apple

Package for persistent and reviewable logs for my apple platform projects.

Project contains the package and a nested demo app `Demo/`.

If you want to run the Demo app, open its project file `Demo/Demo.xcodeproj`.

Import via SPM.

## Logging

The core of this package is the contents of the `Logging` target:
- `LoggerType`
- `DefaultLogger`
- `NoOpLogger`

These are designed to be initialised as static properties in apps or packages as needed.
They are all Sendable and have no issues being referenced across different Actor isolations. 

### LoggerType

Is the core protocol type that all loggers conform to.

### DefaultLogger

The main logger recommended to be used. This will persist logs to a database while also send them to OS logs.

### NoOpLogger

A simple logger that performs no operations, it will not capture anything sent to it.
Potentially useful for when automated tests are running, or you want to support dynamically disabling all logging.

### Recommended Use

Create a `Logger` enum in the project as a namespace with static variables of each logger desired.
You could have one or several as desired.

The "packageName" should be unique across all your projects and meaningful when read for debugging by dev or end user.

You can use `ProcessInfo.processInfo.processName == "xctest"` as a condition to check if tests are running to not initialise  

#### Package example

Set the `packageName` to represent the package. Recommended to use the same name as its public product import.

```swift
enum Logger {
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.processName == "xctest"
    }

    static let networking: any LoggerType = {
        guard isRunningTests else {
            return DefaultLogger(packageName: "networking")
        }

        return NoOpLogger()
    }()
}
```

#### App example

Recommended to set the `packageName` to the bundle identifier.

```swift
enum Logger {
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.processName == "xctest"
    }

    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            preconditionFailure("Unexpected nil Bundle.main.bundleIdentifier")
        }

        return bundleIdentifier
    }

    static let app: any LoggerType = {
        guard isRunningTests else {
            return DefaultLogger(packageName: bundleIdentifier)
        }

        return NoOpLogger()
    }()
}
```

## LoggingUI

Contains views for browsing and exporting the logs in-app. 

## LoggingSettingsGeneratorCommandPlugin

Plugin that finds all `Settings.bundle` locations in the project and injects the `Logging` settings.

For now there has been no logic to also inject it into the Root.plist file, 
so configuring it as a `PSChildPaneSpecifier` to navigate to `Logging.plist` is a manual step.
Something like this:

```
<dict>
    <key>Type</key>
    <string>PSChildPaneSpecifier</string>
    <key>Title</key>
    <string>logging_title</string>
    <key>File</key>
    <string>Logging</string>
</dict>
```

## Disclaimer

This project is open source and open to anyone to use as they see fit.
But I am building this with myself as the main target audience, so this will not be published anywhere.

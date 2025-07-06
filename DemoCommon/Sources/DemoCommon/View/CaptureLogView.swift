// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

/// Triggers logs to populate the database.
struct CaptureLogSection: View {
    @Environment(\.logSchedulerService) var logSchedulerService

    @State private var captureError = false
    @State private var message = "Example message"
    @State private var selectedLogLevel = LogLevel.debug
    @State private var selectedCaptureType = LogCaptureType.once
    @State private var scheduledLogs: [ScheduledLog] = []

    var body: some View {
        Section {
            ConfigurationPicker(
                options: LogLevel.allCases,
                selectedLogLevel: $selectedLogLevel,
                textProvider: \.label
            ) {
                Text(
                    "select_log_level",
                    bundle: .module,
                    comment: "Instructs the user to select a log level in the related picker."
                )
            }

            ConfigurationPicker(
                options: LogCaptureType.allCases,
                selectedLogLevel: $selectedCaptureType,
                textProvider: \.label
            ) {
                Text(
                    "select_trigger_type",
                    bundle: .module,
                    comment: "Instructs the user to the trigger type in the related picker."
                )
            }

            TextField(text: $message) {
                Text(
                    "message_title",
                    bundle: .module,
                    comment: "Title of the text field a user can use to input a message for the log."
                )
            }

            Toggle(isOn: $captureError) {
                Text(
                    "include_error_title",
                    bundle: .module,
                    comment: "Title of toggle for enabling or disabling if an error object is attached to the log."
                )
            }

            Button(action: captureLog) {
                Text(
                    "capture_log_button_title",
                    bundle: .module,
                    comment: "Title of button to trigger log to be send."
                )
            }
        }

//        Section {
//
//        } header: {
//            <#code#>
//        }
    }

    private func captureLog() {
        let error = captureError ? ExampleError() : nil

        switch selectedCaptureType {
        case .once:
            logSchedulerService.capture(
                logLevel: selectedLogLevel,
                message: message,
                error: error
            )
        case .scheduled:
            let id = logSchedulerService.scheduleCaptures(
                logLevel: selectedLogLevel,
                message: message,
                error: error
            )

            scheduledLogs.append(
                ScheduledLog(
                    id: id,
                    logLevel: selectedLogLevel,
                    message: message,
                    error: error
                )
            )
        }
    }
}

extension CaptureLogSection {
    fileprivate enum LogCaptureType: CaseIterable, Hashable {
        case once
        case scheduled
    }

    fileprivate struct ExampleError: LocalizedError {
        var errorDescription: String? {
            "ExampleError: Something went wrong! \(UUID().uuidString)"
        }
    }

    fileprivate struct ScheduledLog: Identifiable {
        let id: UUID
        let logLevel: LogLevel
        let message: String
        let error: (any Error)?
    }
}

extension CaptureLogSection.LogCaptureType {
    var label: Text {
        switch self {
        case .once:
            Text(
                "log_capture_type_label_once",
                bundle: .module,
                comment: "The log will only be sent one time."
            )
        case .scheduled:
            Text(
                "log_capture_type_label_scheduled",
                bundle: .module,
                comment: "The log will be scheduled to happen on a loop."
            )
        }
    }
}

extension LogLevel {
    fileprivate var label: Text {
        switch self {
        case .debug: .LogLevel.debug
        case .info: .LogLevel.info
        case .error: .LogLevel.error
        case .critical: .LogLevel.critical
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CaptureLogSection()
        }
    }
}

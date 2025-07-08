// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingUI
import SwiftUI

/// Triggers logs to populate the database.
struct CaptureLogSection: View {
    // MARK: - State

    @Binding private var presentingStyle: LogsViewPresentingStyle
    @Environment(\.logSchedulerService) private var logSchedulerService
    @State private var captureError = false
    @State private var message = "Example message"
    @State private var selectedLogLevel = LogLevel.debug
    @State private var selectedCaptureType = LogCaptureType.once
    @State private var scheduledLogs: [UUID: ScheduledLog]

    private let scheduledLogSortComparator = ScheduledLogSortComparator()

    init(presentingStyle: Binding<LogsViewPresentingStyle>) {
        self._presentingStyle = presentingStyle
        scheduledLogs = [:]
    }

    /// Initialiser for Preview.
    fileprivate init(
        presentingStyle: LogsViewPresentingStyle,
        scheduledLogs: [UUID: ScheduledLog]
    ) {
        self._presentingStyle = Binding(
            get: { presentingStyle },
            set: { _ in }
        )
        self.scheduledLogs = scheduledLogs
    }

    // MARK: - View

    var body: some View {
        Section {
            presentingStylePicker
        }

        Section {
            selectedLogLevelPicker
            selectedCaptureTypePicker
            messageTextField
            captureErrorToggle
            captureLogButton
        }

        Section {
            scheduledLogsSectionContents
        }
    }

    // MARK: Private Views

    private var captureErrorToggle: some View {
        Toggle(isOn: $captureError) {
            Text(
                "include_error_title",
                bundle: .module,
                comment: "Title of toggle for enabling or disabling if an error object is attached to the log."
            )
        }
    }

    private var captureLogButton: some View {
        Button(action: captureLog) {
            Text(
                "capture_log_button_title",
                bundle: .module,
                comment: "Title of button to trigger log to be send."
            )
        }
    }

    private var messageTextField: some View {
        TextField(text: $message) {
            Text(
                "message_title",
                bundle: .module,
                comment: "Title of the text field a user can use to input a message for the log."
            )
        }
        .textFieldStyle(.roundedBorderIfSupported)
    }

    private var presentingStylePicker: some View {
        ConfigurationPicker(
            options: PresentingType.allCases,
            selectedLogLevel: $presentingStyle,
            optionMapper: \.presentingStyle,
            textProvider: \.label
        ) {
            Text(
                "select_way_to_present_logs",
                bundle: .module,
                comment: "Instructs the user to select how to present the logs view in the related picker."
            )
        }
    }

    private func scheduledLogRow(log: ScheduledLog) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                log.logLevel.label

                Text(verbatim: log.message)
                    .font(.subheadline)

                if let error = log.error {
                    Text(verbatim: "\(error.localizedDescription) (\(error))")
                        .font(.subheadline)
                }

                Text(log.timestamp, style: .relative)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                cancelSchedule(log: log)
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .tint(.red)
            .frame(minWidth: 44, minHeight: 44)
        }
        .frame(maxWidth: .infinity)
    }

    private var scheduledLogsSectionContents: some View {
        ForEach(
            scheduledLogs.values.sorted(using: scheduledLogSortComparator),
            id: \.id
        ) { log in
            scheduledLogRow(log: log)
        }
    }

    private var selectedCaptureTypePicker: some View {
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
    }

    private var selectedLogLevelPicker: some View {
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
    }

    // MARK: - Actions

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

            scheduledLogs[id] = ScheduledLog(
                id: id,
                logLevel: selectedLogLevel,
                message: message,
                error: error,
                timestamp: Date()
            )
        }
    }

    private func cancelSchedule(log: ScheduledLog) {
        logSchedulerService.cancelCaptures(id: log.id)

        withAnimation {
            scheduledLogs[log.id] = nil
        }
    }
}

#Preview {
    @Previewable @State var presentingStyle = LogsViewPresentingStyle.modal
    @Previewable @State var scheduledLogs = LogLevel.allCases
        .map {
            (UUID(), $0)
        }
        .enumerated()
        .reduce(into: [UUID: ScheduledLog]()) { partialResult, element in
            let (offset, (id, logLevel)) = element
            partialResult[id] = ScheduledLog(
                id: id,
                logLevel: logLevel,
                message: "Blah, blah, blah",
                error: offset % 2 == 0 ? nil : ExampleError(),
                timestamp: Date(timeIntervalSinceNow: TimeInterval(offset * -65))
            )
        }

    NavigationStack {
        List {
            CaptureLogSection(presentingStyle: presentingStyle, scheduledLogs: scheduledLogs)
                .logSchedulerService(MockLogSchedulerService())
        }
    }
}

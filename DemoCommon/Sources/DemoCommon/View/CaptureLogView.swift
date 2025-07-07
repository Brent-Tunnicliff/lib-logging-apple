// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import LoggingUI
import SwiftUI

/// Triggers logs to populate the database.
struct CaptureLogSection: View {
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

    // MARK: - Views

    var body: some View {
        Section {
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
            .messageTextFieldStyle

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

        Section {
            ForEach(
                scheduledLogs.values.sorted(using: scheduledLogSortComparator),
                id: \.id
            ) { log in
                scheduledLogRow(log: log)
            }
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

extension View {
    fileprivate var messageTextFieldStyle: some View {
        #if os(watchOS) || os(tvOS)
            textFieldStyle(.automatic)
        #else
            textFieldStyle(.roundedBorder)
        #endif
    }
}

private struct ScheduledLogSortComparator: SortComparator {
    var order: SortOrder = .forward

    func compare(_ lhs: CaptureLogSection.ScheduledLog, _ rhs: CaptureLogSection.ScheduledLog) -> ComparisonResult {
        guard lhs.timestamp != rhs.timestamp else {
            return lhs.id < rhs.id ? .orderedDescending : .orderedAscending
        }

        return lhs.timestamp < rhs.timestamp ? .orderedDescending : .orderedAscending
    }
}

extension CaptureLogSection {
    fileprivate enum PresentingType: CaseIterable {
        case navigationDestination
        case modal
    }

    fileprivate enum LogCaptureType: CaseIterable, Hashable {
        case once
        case scheduled
    }

    fileprivate struct ExampleError: LocalizedError {
        var errorDescription: String? {
            "ExampleError: Something went wrong! \(UUID().uuidString)"
        }
    }

    fileprivate struct ScheduledLog {
        let id: UUID
        let logLevel: LogLevel
        let message: String
        let error: (any Error)?
        let timestamp: Date
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

extension CaptureLogSection.PresentingType {
    var label: Text {
        switch self {
        case .navigationDestination:
            Text(
                "presenting_type_navigation_destination",
                bundle: .module,
                comment: "Sets the presenting option to default navigation"
            )
        case .modal:
            Text(
                "presenting_type_modal",
                bundle: .module,
                comment: "Sets the presenting option to a modal sheet or window"
            )
        }
    }

    var presentingStyle: LogsViewPresentingStyle {
        switch self {
        case .navigationDestination: .navigationDestination
        case .modal: .modal
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

private struct PreviewError: Error {}

#Preview {
    @Previewable @State var presentingStyle = LogsViewPresentingStyle.modal
    @Previewable @State var scheduledLogs = LogLevel.allCases
        .map {
            (UUID(), $0)
        }
        .enumerated()
        .reduce(into: [UUID: CaptureLogSection.ScheduledLog]()) { partialResult, element in
            let (offset, (id, logLevel)) = element
            partialResult[id] = CaptureLogSection.ScheduledLog(
                id: id,
                logLevel: logLevel,
                message: "Blah, blah, blah",
                error: offset % 2 == 0 ? nil : PreviewError(),
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

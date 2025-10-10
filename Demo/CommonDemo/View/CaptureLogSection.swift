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
    @State private var isPopulatingManyLogsProgress = 0
    @State private var message = "Example message"
    @State private var selectedLogLevel = LogLevel.debug
    @State private var selectedCaptureType = LogCaptureType.once
    @State private var scheduledLogs: [UUID: ScheduledLog]

    private let scheduledLogSortComparator = ScheduledLogSortComparator()

    private var errorToLog: (any Error)? {
        captureError ? ExampleError() : nil
    }

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
            populateManyLogsSectionContents
        } footer: {
            if isPopulatingManyLogsProgress > 0 {
                Text(isPopulatingManyLogsProgress.description)
            }
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
            Text(.includeErrorTitle)
        }
    }

    private var captureLogButton: some View {
        Button(action: captureLog) {
            Text(.captureLogButtonTitle)
        }
    }

    private var populateManyLogsSectionContents: some View {
        Button {
            let range = 0...100_000
            isPopulatingManyLogsProgress = range.count
            Task { @concurrent in
                for _ in range {
                    Logger.app.debug("This is an example debug log without an error")
                    Logger.app.debug("This is an example debug log with an error", error: ExampleError())
                    Logger.app.info("This is an example info log without an error")
                    Logger.app.info("This is an example info log with an error", error: ExampleError())
                    Logger.app.error("This is an example error log without an error")
                    Logger.app.error("This is an example error log with an error", error: ExampleError())
                    Logger.app.critical("This is an example critical log without an error")
                    Logger.app.critical("This is an example critical log with an error", error: ExampleError())

                    Task { @MainActor in
                        isPopulatingManyLogsProgress -= 1
                    }
                }
            }
        } label: {
            Text(.populateManyLogsButtonTitle)
        }
        .disabled(isPopulatingManyLogsProgress > 0)
    }

    private var messageTextField: some View {
        TextField(text: $message) {
            Text(.messageTitle)
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
            Text(.selectWayToPresentLogs)
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
            Text(.selectTriggerType)
        }
    }

    private var selectedLogLevelPicker: some View {
        ConfigurationPicker(
            options: LogLevel.allCases,
            selectedLogLevel: $selectedLogLevel,
            textProvider: \.label
        ) {
            Text(.selectLogLevel)
        }
    }

    // MARK: - Actions

    private func captureLog() {
        let error = errorToLog
        let message = message
        let selectedLogLevel = selectedLogLevel

        guard let seconds = selectedCaptureType.scheduledSeconds else {
            logSchedulerService.capture(
                logLevel: selectedLogLevel,
                message: message,
                error: error
            )
            return
        }

        let id = logSchedulerService.scheduleCaptures(
            every: seconds,
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

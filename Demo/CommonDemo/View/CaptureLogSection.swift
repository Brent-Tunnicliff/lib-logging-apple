// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import CommonUI
import Logging
import LoggingUI
import SwiftUI

/// Triggers logs to populate the database.
struct CaptureLogSection: View {
    // MARK: - State

    @Binding private var presentingStyle: LogsViewPresentingStyle
    @Environment(\.logSchedulerService) private var logSchedulerService
    @FocusState private var focusedField
    @State private var captureError = false
    @State private var isPopulatingManyLogsProgress = 0
    @State private var message = "Example message"
    @State private var selectedLogLevel = LogLevel.debug
    @State private var selectedCaptureType = LogCaptureType.once
    @State private var scheduledLogs: [UUID: ScheduledLog]
    @State private var numberOfLogsToGenerate = 1_000

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

    @ViewBuilder
    private var populateManyLogsSectionContents: some View {
        // Since it is a simple demo app I won't bother with inout validation beyond the very basic.
        TextField(
            .populateManyLogsNumber,
            value: $numberOfLogsToGenerate,
            formatter: NumberFormatter()
        )
        .keyboardTypeNumberPadIfSupported()
        .focused($focusedField)
        .toolbarKeyboardCloseButtonIfSupported(focused: $focusedField)

        Button {
            let range = 0...numberOfLogsToGenerate
            isPopulatingManyLogsProgress = range.count
            focusedField = false
            Task { @concurrent in
                let logger = Logger.app
                for _ in range {
                    let logActions: [() -> Void] = [
                        { logger.debug("This is an example debug log without an error") },
                        { logger.debug("This is an example debug log with an error", error: ExampleError()) },
                        { logger.info("This is an example info log without an error") },
                        { logger.info("This is an example info log with an error", error: ExampleError()) },
                        { logger.error("This is an example error log without an error") },
                        { logger.error("This is an example error log with an error", error: ExampleError()) },
                        { logger.critical("This is an example critical log without an error") },
                        { logger.critical("This is an example critical log with an error", error: ExampleError()) },
                    ]

                    guard let logAction = logActions.randomElement() else {
                        preconditionFailure("No log action to perform.")
                    }

                    logAction()

                    // Wait for the count update before moving on
                    _ = await Task { @MainActor in
                        isPopulatingManyLogsProgress -= 1

                        // Periodically save logs, better to slow down the loop than be left will massive amount
                        // of saves happing when navigating to
                        if isPopulatingManyLogsProgress % 100 == 0 {
                            try await logger._savePendingLogs()
                        }
                    }.result
                }

                try await logger._savePendingLogs()
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
        .textFieldStyleRoundedBorderIfSupported()
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

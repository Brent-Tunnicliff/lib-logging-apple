// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Logging
import SwiftUI

/// Triggers logs to populate the database.
struct CaptureLogView: View {
    @Environment(\.logSchedulerService) var logSchedulerService

    @State private var captureError = false
    @State private var message = "Example message"
    @State private var selectedLogLevel = LogLevel.debug
    @State private var selectedCaptureType = CaptureLogView.LogCaptureType.once

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ConfigurationPicker(
                    options: LogLevel.allCases,
                    selectedLogLevel: $selectedLogLevel,
                    textProvider: \.label
                ) {
                    Text("Select Log Level")
                }

                ConfigurationPicker(
                    options: CaptureLogView.LogCaptureType.allCases,
                    selectedLogLevel: $selectedCaptureType,
                    textProvider: \.label
                ) {
                    Text("Select Log Level")
                }

                TextField(text: $message) {
                    Text("Message")
                }

                Toggle(isOn: $captureError) {
                    Text("Capture error")
                }

                Button(action: captureLog) {
                    Text("Capture log")
                }
            }
        }
        .padding()
        .task {
            await logSchedulerService.stopCaptures()
        }
    }

    private func captureLog() {
        let error = captureError ? ExampleError() : nil

        Task {
            switch selectedCaptureType {
            case .once:
                await logSchedulerService.capture(
                    logLevel: selectedLogLevel,
                    message: message,
                    error: error
                )
            case .scheduled:
                await logSchedulerService.scheduleCaptures(
                    logLevel: selectedLogLevel,
                    message: message,
                    error: error
                )
            }
        }
    }
}

extension CaptureLogView {
    fileprivate enum LogCaptureType: CaseIterable, Hashable {
        case once
        case scheduled
    }

    fileprivate struct ExampleError: LocalizedError {
        var errorDescription: String? {
            "ExampleError: Something went wrong! \(UUID().uuidString)"
        }
    }
}

extension CaptureLogView.LogCaptureType {
    var label: String {
        switch self {
        case .once: "Once"
        case .scheduled: "Every second"
        }
    }
}

extension LogLevel {
    fileprivate var label: String {
        switch self {
        case .debug: "Debug"
        case .info: "Info"
        case .error: "Error"
        case .critical: "Critical"
        default: "Unknown"
        }
    }
}

#Preview {
    CaptureLogView()
}

// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

extension View {
    func exportLogsSheet(exportFileState: Binding<ExportFileState?>) -> some View {
        sheet(item: exportFileState) {
            ExportLogsView(exportFileState: $0)
                .presentationDragIndicator(.visible)
        }
    }
}

@Observable
final class ExportFileState: Identifiable {
    private(set) var error: (any Error)?
    private(set) var file: URL?
    private(set) var progress: Double

    convenience init() {
        self.init(error: nil, file: nil, progress: 0)
    }

    fileprivate init(
        error: (any Error)?,
        file: URL?,
        progress: Double
    ) {
        self.error = error
        self.file = file
        self.progress = progress
    }

    func inject(file: URL) {
        self.file = file
    }

    func inject(error: any Error) {
        self.error = error
    }

    func inject(progress: Double) {
        self.progress = progress
    }
}

private struct ExportLogsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exportFileState: ExportFileState

    init(exportFileState: ExportFileState) {
        #if os(tvOS)
            preconditionFailure("Exporting logs not supported in tvOS")
        #endif

        self._exportFileState = State(wrappedValue: exportFileState)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ProgressView(
                    exportFileState.progressTitle,
                    value: exportFileState.progress
                )

                if let exportFile = exportFileState.file {
                    shareLink(exportFile: exportFile)
                } else if let error = exportFileState.error {
                    Text(.preparingExportFailed(error: error.localizedDescription))
                }

                Spacer()
            }
            .padding()
            .toolbar {
                Button(role: .close, action: dismiss.callAsFunction)
            }
        }
    }

    private func shareLink(exportFile: URL) -> some View {
        #if os(tvOS)
            Text(verbatim: "NOT SUPPORTED")
        #else
            ShareLink(item: exportFile)
        #endif
    }
}

extension ExportFileState {
    fileprivate var progressTitle: LocalizedStringResource {
        if file != nil {
            .exportFileReady
        } else if error != nil {
            .exportFailed
        } else {
            .preparingExport
        }
    }
}

#Preview {
    @Previewable @State var exportFileState: ExportFileState? = ExportFileState()
    @Previewable @State var taskID = UUID()

    VStack(spacing: 16) {
        Button("Export") {
            exportFileState = ExportFileState()
            taskID = UUID()
        }

        Button("Export error") {
            exportFileState = ExportFileState()
            taskID = UUID()
            Task {
                try await Task.sleep(for: .seconds(1))
                exportFileState?.inject(error: PreviewError())
            }
        }
    }
    .exportLogsSheet(exportFileState: $exportFileState)
    .task(id: taskID) {
        guard let exportFileState else {
            return
        }

        do {
            try await Task.sleep(for: .seconds(1))
            exportFileState.inject(progress: 0.3)

            try await Task.sleep(for: .seconds(1))
            exportFileState.inject(progress: 0.6)

            try await Task.sleep(for: .seconds(1))
            exportFileState.inject(progress: 1)

            if exportFileState.error == nil {
                exportFileState.inject(file: .Preview.textFile)
            }
        } catch {}
    }
}

private struct PreviewError: Error {}

// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

extension View {
    func exportLogsSheet(exportFileState: Binding<ExportFileState?>) -> some View {
        sheet(item: exportFileState) {
            ExportLogsView(exportFileState: $0)
        }
    }
}

@Observable
final class ExportFileState: Identifiable, Equatable {
    private(set) var exportFile: URL?
    private(set) var exportError: (any Error)?

    convenience init() {
        self.init(exportFile: nil, exportError: nil)
    }

    fileprivate init(
        exportFile: URL?,
        exportError: (any Error)?
    ) {
        self.exportFile = exportFile
        self.exportError = exportError
    }

    func inject(exportFile: URL) {
        self.exportFile = exportFile
    }

    func inject(exportError: any Error) {
        self.exportError = exportError
    }

    static func == (lhs: ExportFileState, rhs: ExportFileState) -> Bool {
        lhs.id == rhs.id
            && lhs.exportFile == rhs.exportFile
            && lhs.exportError?.localizedDescription == rhs.exportError?.localizedDescription
    }
}

private struct ExportLogsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exportFileState: ExportFileState

    init(exportFileState: ExportFileState) {
        self._exportFileState = State(wrappedValue: exportFileState)
    }

    var body: some View {
        NavigationStack {
            if let error = exportFileState.exportError {
                Text(.preparingExportFailed(error: error.localizedDescription))
            } else if let exportFile = exportFileState.exportFile {
                activityView(url: exportFile)
            } else {
                preparingExport
            }
        }
    }

    private var preparingExport: some View {
        ProgressView(.preparingExport)
            .toolbar {
                Button(role: .close, action: dismiss.callAsFunction)
            }
    }

    private func activityView(url: URL) -> some View {
        #if os(iOS)
            UIKitExportActivityView(url: url)
        #else
            // TODO: implement other platforms
            Text(verbatim: "Coming soon...")
        #endif
    }
}

#if os(iOS)
    import UIKit

    private struct UIKitExportActivityView: UIViewControllerRepresentable {
        private let activityViewController: UIActivityViewController

        init(url: URL) {
            self.activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }

        func makeUIViewController(context: Context) -> UIActivityViewController {
            activityViewController
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {

        }
    }
#else
    // NSViewControllerRepresentable?
#endif

#Preview {
    @Previewable @State var exportFileState: ExportFileState? = ExportFileState(
        exportFile: nil,
        exportError: nil
    )

    VStack(spacing: 16) {
        Button("Export") {
            exportFileState = ExportFileState(
                exportFile: nil,
                exportError: nil
            )
        }

        Button("Export error") {
            exportFileState = ExportFileState(
                exportFile: nil,
                exportError: PreviewError()
            )
        }
    }
    .exportLogsSheet(exportFileState: $exportFileState)
    .task(id: exportFileState) {
        do {
            try await Task.sleep(for: .seconds(3))
            if let exportFileState, exportFileState.exportError == nil {
                exportFileState.inject(exportFile: .Preview.textFile)
            }
        } catch {}
    }
}

private struct PreviewError: Error {}

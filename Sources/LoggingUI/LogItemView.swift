// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingCore
import SwiftData
import SwiftUI

struct LogItemView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var isExpanded: Bool

    private let log: LogEntity

    init(log: LogEntity, initialExpandedValue: Bool = false) {
        self.log = log
        self._isExpanded = State(initialValue: initialExpandedValue)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                logLevelLabel
                messageLabel
                errorLabel
                packageNameLabel
                tagLabel
                timestampLabel
                expandedView
            }

            Spacer()

            chevronImage
        }
        .lineLimit(isExpanded ? nil : 3)
        .listRowBackground(
            backgroundColor
                .opacity(0.2)
        )
        .padding(.bottom, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }

    private var backgroundColor: Color {
        switch log.level {
        case .critical: .red
        case .debug, .info: .clear
        case .error: .orange
        }
    }

    @ViewBuilder
    private var chevronImage: some View {
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .contentTransition(.symbolEffect(.replace, options: .speed(3)))
    }

    @ViewBuilder
    private var expandedView: some View {
        if isExpanded {
            Divider()

            VStack(alignment: .leading) {
                logIdLabel
                deviceIdentifierForVendorLabel
                deviceModelLabel
                deviceSystemLabel
                deviceUserInterfaceIdiomLabel
            }
            .padding(.leading, 8)
        }
    }

    // MARK: - Labels

    @ViewBuilder
    private var deviceIdentifierForVendorLabel: some View {
        Group {
            if let identifierForVendor = log.device.identifierForVendor {
                Text("identifier_for_vendor_\(identifierForVendor)", bundle: .module)
            } else {
                Text("identifier_for_vendor_unknown", bundle: .module)
            }
        }
        .font(.caption2)
    }

    @ViewBuilder
    private var deviceModelLabel: some View {
        Group {
            if let model = log.device.model {
                Text("device_model_\(model)", bundle: .module)
            } else {
                Text("device_model_unknown", bundle: .module)
            }
        }
        .font(.caption2)
    }

    @ViewBuilder
    private var deviceSystemLabel: some View {
        Group {
            switch (log.device.systemName, log.device.systemVersion) {
            case (nil, nil): Text("device_system_unknown", bundle: .module)
            case let (nil, systemVersion): Text(systemVersion ?? "")
            case let (systemName, nil): Text(systemName ?? "")
            case let (systemName, systemVersion): Text(verbatim: "\(systemName ?? "") \(systemVersion ?? "")")
            }
        }
        .font(.caption2)
    }

    @ViewBuilder
    private var deviceUserInterfaceIdiomLabel: some View {
        Group {
            switch log.device.userInterfaceIdiom {
            case .carPlay: Text("device_user_interface_idiom_carPlay", bundle: .module)
            case .mac: Text("device_user_interface_idiom_mac", bundle: .module)
            case .pad: Text("device_user_interface_idiom_pad", bundle: .module)
            case .phone: Text("device_user_interface_idiom_phone", bundle: .module)
            case .tv: Text("device_user_interface_idiom_tv", bundle: .module)
            case .unspecified: Text("device_user_interface_idiom_unspecified", bundle: .module)
            case .vision: Text("device_user_interface_idiom_vision", bundle: .module)
            case .watch: Text("device_user_interface_idiom_watch", bundle: .module)
            }
        }
        .font(.caption2)
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let error = log.error {
            Text("log_error_title_\(error.type)_\(error.message)", bundle: .module)
        }
    }

    @ViewBuilder
    private var logIdLabel: some View {
        Text("log_id_\(log.id.uuidString)", bundle: .module)
            .font(.caption2)
    }

    @ViewBuilder
    private var logLevelLabel: some View {
        Group {
            switch log.level {
            case .critical: Text("log_level_critical", bundle: .module)
            case .debug: Text("log_level_debug", bundle: .module)
            case .info: Text("log_level_info", bundle: .module)
            case .error: Text("log_level_error", bundle: .module)
            }
        }
        .font(.footnote)
    }

    @ViewBuilder
    private var messageLabel: some View {
        // No current plans to have our log messages localized as that will be difficult to maintain,
        // so will just be what ever the message the developer wrote.
        // Unfortunate if any non-english speakers use this.
        Text(log.message)
    }

    @ViewBuilder
    private var packageNameLabel: some View {
        Text(log.packageName)
            .font(.caption2)
    }

    @ViewBuilder
    private var tagLabel: some View {
        Text(
            layoutDirectionBasedText(
                inputs: [
                    log.tag.file,
                    log.tag.function,
                    log.tag.line.description,
                ],
                separator: ":"
            )
        )
        .font(.caption2)
    }

    @ViewBuilder
    private var timestampLabel: some View {
        Text(log.timestampCreated, format: Date.FormatStyle(date: .abbreviated, time: .complete))
            .font(.caption2)
    }

    private func layoutDirectionBasedText(inputs: [String], separator: String) -> String {
        let layoutDirectionBasedInputs = layoutDirection == .leftToRight ? inputs : inputs.reversed()
        return layoutDirectionBasedInputs.joined(separator: separator)
    }
}

#if DEBUG
    #Preview {
        let longMessage = """
            This message is very long, so that we can test out wrapping and truncating logic. \
            Blah, blah, blah. How about this weather huh? It has been raining lots tonight. \
            Luckily it was not raining while I was outside.
            """
        List {
            Section("Expanded") {
                LogItemView(
                    log: .mock(),
                    initialExpandedValue: true
                )
            }

            Section("Log levels") {
                ForEach(LogEntity.LogLevel.allCases, id: \.self) {
                    LogItemView(log: .mock(level: $0))
                }
            }

            Section("Truncating") {
                LogItemView(log: .mock(message: longMessage))

                LogItemView(log: .mock(error: .mock(message: longMessage)))

                LogItemView(
                    log: .mock(
                        message: longMessage,
                        error: .mock(message: longMessage)
                    )
                )
            }

            Section("User Interface Idiom") {
                ForEach(LogEntity.UserInterfaceIdiom.allCases, id: \.self) {
                    LogItemView(
                        log: .mock(device: .mock(userInterfaceIdiom: $0)),
                        initialExpandedValue: true
                    )
                }
            }
        }
    }
#endif

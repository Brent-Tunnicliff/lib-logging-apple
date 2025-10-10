// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftUI

/// Common configuration picker.
///
/// Displays as a `Button` and `Sheet` on WatchOS, but as a `SegmentedPickerStyle` on others.
struct ConfigurationPicker<Option: Hashable, Label: View, SelectedOption: Hashable>: View {
    @Binding private var selectedOption: SelectedOption

    private let label: Label
    private let options: [Option]
    private let optionMapper: (Option) -> SelectedOption
    private let textProvider: (Option) -> Text

    init(
        options: [Option],
        selectedLogLevel: Binding<SelectedOption>,
        textProvider: @escaping (Option) -> Text,
        @ViewBuilder label: () -> Label
    ) where Option == SelectedOption {
        self.options = options
        self.optionMapper = { $0 }
        self._selectedOption = selectedLogLevel
        self.textProvider = textProvider
        self.label = label()
    }

    init(
        options: [Option],
        selectedLogLevel: Binding<SelectedOption>,
        optionMapper: @escaping (Option) -> SelectedOption,
        textProvider: @escaping (Option) -> Text,
        @ViewBuilder label: () -> Label
    ) {
        self.options = options
        self.optionMapper = optionMapper
        self._selectedOption = selectedLogLevel
        self.textProvider = textProvider
        self.label = label()
    }

    var body: some View {
        Picker(selection: $selectedOption) {
            ForEach(options, id: \.self) { option in
                textProvider(option)
                    .tag(optionMapper(option))
            }
        } label: {
            label
        }
    }
}

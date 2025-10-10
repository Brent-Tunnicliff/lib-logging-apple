// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import LoggingUI
import SwiftUI

enum PresentingType: CaseIterable {
    case navigationDestination
    case modal
}

// MARK: - LogsViewPresentingStyle

extension PresentingType {
    var presentingStyle: LogsViewPresentingStyle {
        switch self {
        case .navigationDestination: .navigationDestination
        case .modal: .modal
        }
    }
}

// MARK: - View

extension PresentingType {
    var label: Text {
        switch self {
        case .navigationDestination:
            Text(.presentingTypeNavigationDestination)
        case .modal:
            Text(.presentingTypeModal)
        }
    }
}

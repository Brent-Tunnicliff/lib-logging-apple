// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import SnapshotTesting
// TODO: test if `SnapshotTestingHEIC` is worth it.
import SnapshotTestingHEIC
import SwiftUI

enum Snapshot {
    func assert<Content>(of value: @autoclosure () -> Content) where Content: View {
//        withSnapshotTesting {
        SnapshotTesting.assertSnapshot(of: value(), as: .snapshotFormat)
//        }

    }
}

//#if os(iOS) || os(tvOS)
//@available(iOS 13.0, tvOS 13.0, *)
//public extension Snapshotting where Value: SwiftUI.View, Format == UIImage {

#if canImport(UIKit)
    import UIKit

    extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
        fileprivate static var snapshotFormat: Snapshotting {
            .imageHEIC()
        }
    }
#elseif canImport(AppKit)
    import AppKit

    extension Snapshotting where Value: SwiftUI.View, Format == NSImage {
        fileprivate static var snapshotFormat: Snapshotting {
            .imageHEIC()
        }
    }
#endif

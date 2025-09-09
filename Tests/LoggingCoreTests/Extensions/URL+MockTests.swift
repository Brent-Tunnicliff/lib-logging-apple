// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import LoggingCore
import Testing

@Suite("URL+MockTests")
struct URLMockTests {
    @Test()
    func mockDoesNotCrash() {
        // No need to expect.
        // Initialising URL from string returns optional type, so crashing if nil.
        // So wanted to add a very simple test that the mock I may use in other tests/previews
        // is not crashing, even though risk is very low.
        let _: URL = .mock
    }
}

// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

@testable import Logging

struct DeviceTests {
    @Test
    func currentReturnsValue() async {
        // Different destinations return different values, so no value in check values.
        // But the purpose of this test is just that it compiles and no exceptions were thrown.
        _ = await Device.current
    }

    // Manually defining the mappings to also make sure that every RawValue case has a matching static constant.
    private static let expectedUserInterfaceIdiomContainsAllCasesMappings:
        [Device.UserInterfaceIdiom: Device.UserInterfaceIdiom.RawValue] = [
            .carPlay: .carPlay,
            .mac: .mac,
            .pad: .pad,
            .phone: .phone,
            .tv: .tv,
            .unspecified: .unspecified,
            .vision: .vision,
            .watch: .watch,
        ]

    @Test(arguments: Device.UserInterfaceIdiom.allCases)
    func userInterfaceIdiomContainsAllCases(userInterfaceIdiom: Device.UserInterfaceIdiom) {
        let expectedValue = Self.expectedUserInterfaceIdiomContainsAllCasesMappings[userInterfaceIdiom]
        #expect(userInterfaceIdiom.rawValue == expectedValue)
    }
}

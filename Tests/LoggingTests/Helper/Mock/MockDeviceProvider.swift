// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import Logging

actor MockDeviceProvider: DeviceProvider {
    private var device = Device.mock()

    func current() async -> Device {
        device
    }

    func inject(device: Device) {
        self.device = device
    }
}

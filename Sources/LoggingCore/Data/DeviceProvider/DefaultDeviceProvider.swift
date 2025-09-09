// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

package final class DefaultDeviceProvider: DeviceProvider {
    package func currentDevice() async -> Device {
        await Device.current
    }
}

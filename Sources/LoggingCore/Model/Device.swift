// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation

// MARK: - Device

/// Information about the device.
package struct Device {
    /// Unique identifier of this app install. `nil` if unable to get the real value.
    let identifierForVendor: UUID?

    /// Device model identifier. `nil` if unable to get the real value.
    let model: String?

    /// Name of the OS system. `nil` if unable to get the real value.
    let systemName: String?

    /// Version of the OS system. `nil` if unable to get the real value.
    let systemVersion: String?

    /// Type of user interface of the device.
    let userInterfaceIdiom: UserInterfaceIdiom
}

extension Device: Codable {}
extension Device: Equatable {}
extension Device: Sendable {}

extension Device {
    /// Returns the details of the current device.
    @MainActor
    static let current: Device = {
        #if canImport(WatchKit)
            currentWatchKit()
        #elseif canImport(UIKit)
            currentUIKit()
        #elseif canImport(IOKit)
            currentIOKit()
        #endif
    }()
}

// MARK: - UserInterfaceIdiom

extension Device {
    package struct UserInterfaceIdiom {
        let rawValue: RawValue

        fileprivate init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension Device.UserInterfaceIdiom: Codable {}
extension Device.UserInterfaceIdiom: Equatable {}
extension Device.UserInterfaceIdiom: Hashable {}
extension Device.UserInterfaceIdiom: Sendable {}

extension Device.UserInterfaceIdiom: CustomStringConvertible {
    package var description: String {
        "\(rawValue)"
    }
}

extension Device.UserInterfaceIdiom {
    /// CarPlay user interface type.
    package static let carPlay = Device.UserInterfaceIdiom(rawValue: .carPlay)

    /// Mac user interface type.
    package static let mac = Device.UserInterfaceIdiom(rawValue: .mac)

    /// Tablet user interface type.
    package static let pad = Device.UserInterfaceIdiom(rawValue: .pad)

    /// Phone user interface type.
    package static let phone = Device.UserInterfaceIdiom(rawValue: .phone)

    /// TV user interface type.
    package static let tv = Device.UserInterfaceIdiom(rawValue: .tv)

    /// Unknown user interface type.
    package static let unspecified = Device.UserInterfaceIdiom(rawValue: .unspecified)

    /// Vision user interface type.
    package static let vision = Device.UserInterfaceIdiom(rawValue: .vision)

    /// Watch user interface type.
    package static let watch = Device.UserInterfaceIdiom(rawValue: .watch)
}

extension Device.UserInterfaceIdiom: CaseIterable {
    package static let allCases: [Device.UserInterfaceIdiom] = RawValue.allCases.compactMap {
        Device.UserInterfaceIdiom(rawValue: $0)
    }
}

// MARK: - RawValue

extension Device.UserInterfaceIdiom {
    // Keeping the enum internal to minimise the risk of breaking changes if this changes.
    enum RawValue: String {
        case carPlay
        case mac
        case pad
        case phone
        case tv
        case unspecified
        case vision
        case watch
    }
}

extension Device.UserInterfaceIdiom.RawValue: Codable {}
extension Device.UserInterfaceIdiom.RawValue: CaseIterable {}

// MARK: - Constants

// The order of these are important as some platforms can contain multiple.

#if canImport(WatchKit)

    // MARK: WatchKit

    import WatchKit

    extension Device {
        fileprivate static func currentWatchKit() -> Device {
            let device = WKInterfaceDevice.current()
            return Device(
                identifierForVendor: device.identifierForVendor,
                model: device.model,
                systemName: device.systemName,
                systemVersion: device.systemVersion,
                userInterfaceIdiom: .watch
            )
        }
    }

#elseif canImport(UIKit)

    // MARK: UIKit

    import UIKit

    extension UIUserInterfaceIdiom {
        var asUserInterfaceIdiom: Device.UserInterfaceIdiom {
            Device.UserInterfaceIdiom(rawValue: asRawValue)
        }

        private var asRawValue: Device.UserInterfaceIdiom.RawValue {
            switch self {
            case .carPlay: .carPlay
            case .mac: .mac
            case .pad: .pad
            case .phone: .phone
            case .tv: .tv
            case .unspecified: .unspecified
            case .vision: .vision
            @unknown default: .unspecified
            }
        }
    }

    extension Device {
        @MainActor
        fileprivate static func currentUIKit() -> Device {
            let device = UIDevice.current
            return Device(
                identifierForVendor: device.identifierForVendor,
                model: device.model,
                systemName: device.systemName,
                systemVersion: device.systemVersion,
                userInterfaceIdiom: device.userInterfaceIdiom.asUserInterfaceIdiom
            )
        }
    }

#elseif canImport(IOKit)

    // MARK: MacOS

    import IOKit

    extension Device {
        fileprivate static func currentIOKit() -> Device {
            let service = IOServiceGetMatchingService(
                kIOMainPortDefault,
                IOServiceMatching("IOPlatformExpertDevice")
            )

            defer {
                IOObjectRelease(service)
            }

            guard service != 0 else {
                // We are unable to use service to get the needed values.
                return Device(
                    identifierForVendor: nil,
                    model: nil,
                    systemName: nil,
                    systemVersion: nil,
                    userInterfaceIdiom: .mac
                )
            }

            let hardwareDeviceId = IORegistryEntryCreateCFProperty(
                service,
                kIOPlatformUUIDKey as CFString,
                kCFAllocatorDefault,
                0
            )

            let hardwareDeviceIdValue = hardwareDeviceId?.takeRetainedValue() as? String

            let modelData = IORegistryEntryCreateCFProperty(
                service,
                "model" as CFString,
                kCFAllocatorDefault,
                0
            )
            let modelDataValue = modelData?.takeRetainedValue() as? Data
            let model: String? =
                if let modelDataValue {
                    String(data: modelDataValue, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
                } else {
                    nil
                }

            return Device(
                identifierForVendor: (hardwareDeviceIdValue).map(UUID.init(uuidString:)) ?? nil,
                model: model,
                systemName: nil,
                systemVersion: ProcessInfo.processInfo.operatingSystemVersion.asSystemVersion,
                userInterfaceIdiom: .mac
            )
        }
    }

    extension OperatingSystemVersion {
        fileprivate var asSystemVersion: String {
            "\(majorVersion).\(minorVersion).\(patchVersion)"
        }
    }

#endif

// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Name space for holding Logger singletons.
///
/// Apps and packages should extend this enum to add their own logs.
public enum Logger {
    internal static let logging: any LoggerType = PersistentLogger(packageName: "logging")
}

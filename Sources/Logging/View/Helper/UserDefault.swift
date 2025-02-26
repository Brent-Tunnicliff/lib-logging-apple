// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

import Combine
import Foundation
import SwiftUI

@MainActor
@propertyWrapper
struct UserDefault<Value>: DynamicProperty {
    private let key: ReferenceWritableKeyPath<UserDefaults, Value>
    private let store: UserDefaults

    // Using @State so the view will update. Logic to keep this synced with store is not great, but will do the job.
    @State private var value: Value

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    var wrappedValue: Value {
        get { value }
        nonmutating set {
            store[keyPath: key] = newValue
            value = newValue
        }
    }

    init(
        key: ReferenceWritableKeyPath<UserDefaults, Value>,
        store: UserDefaults = .standard
    ) {
        self.key = key
        self.store = store
        self._value = State(wrappedValue: store[keyPath: key])
    }
}

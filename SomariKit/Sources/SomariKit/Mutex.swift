import Synchronization

@propertyWrapper
public final class Mutex<Value: Sendable>: Sendable {
    private let value: Synchronization.Mutex<Value>
    public var wrappedValue: Value {
        get {
            value.withLock { value in
                value
            }
        }
        set {
            value.withLock { value in
                value = newValue
            }
        }
    }

    public init(wrappedValue: Value) {
        self.value = .init(wrappedValue)
    }
}

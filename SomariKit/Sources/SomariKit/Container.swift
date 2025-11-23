import Foundation
import Synchronization

@propertyWrapper
public struct Injected<Value> {
    public let wrappedValue: Value

    public init<Key: ContainerKey>(_ type: Key.Type) where Key.Value == Value {
        self.wrappedValue = Container.shared[type]
    }
}

public final class Container: Sendable {
    public static let shared = Container()

#if DEBUG
    public var isTest: Bool {
        get {
            isTestAtomic.load(ordering: .sequentiallyConsistent)
        }
        set {
            isTestAtomic.store(newValue, ordering: .sequentiallyConsistent)
        }
    }

    public let isTestAtomic: Atomic<Bool>
#endif

    public init() {
#if DEBUG
        let isTest = if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            true
        } else {
            false
        }
        self.isTestAtomic = .init(isTest)
#endif
    }

    public subscript<Key: ContainerKey>(_ type: Key.Type) -> Key.Value {
        #if DEBUG
        if isTest {
            type.testValue
        } else {
            type.defaultValue
        }
        #else
        Key.defaultValue
        #endif
    }
}

public protocol ContainerKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static var testValue: Value { get }
}

public extension ContainerKey {
    static var testValue: Value {
        defaultValue
    }
}

import Foundation
import Combine

public protocol Cancellable: Combine.Cancellable {
    func cancel()
}

public struct AnyCancellable: Cancellable, Hashable {
    let cancellable: Combine.AnyCancellable

    public init(_ cancellable: some Cancellable) {
        self.cancellable = .init(cancellable)
    }

    public init(_ action: @escaping () -> Void) {
        self.cancellable = Combine.AnyCancellable(action)
    }

    public func cancel() {
        cancellable.cancel()
    }
}

public extension Cancellable {
    func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(self))
    }
}

extension Task: Cancellable {
}

public extension Task {
    func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(self))
    }
}

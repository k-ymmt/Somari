import Foundation
import Observation

@Observable
final class LaunchViewModel {
    private let completed: () -> Void

    init(completed: @escaping () -> Void) {
        self.completed = completed
        makeEnvironment()
    }
}

private extension LaunchViewModel {
    func makeEnvironment() {
        completed()
    }
}

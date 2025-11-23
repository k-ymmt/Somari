import Foundation
import Observation
import SwiftUI

@Observable
final class PageRouter {
    var path: NavigationPath = .init()

    func makeChildRouter<Path>() -> ChildPageRouter<Path> {
        .init(parent: self)
    }

    func go<Path: Hashable>(to path: Path) {
        self.path.append(path)
    }

    func goBack() {
        guard path.count > 1 else {
            return
        }
        path.removeLast()
    }

    func goRoot() {
        path.removeLast(path.count)
    }
}

struct ChildPageRouter<Path: Hashable> {
    private let parent: PageRouter

    fileprivate init(parent: PageRouter) {
        self.parent = parent
    }

    func go(to path: Path) {
        parent.go(to: path)
    }

    func goBack() {
        parent.goBack()
    }

    func goRoot() {
        parent.goRoot()
    }
}

import Foundation
import Observation

@Observable
final class ArticleViewModel {
    let url: URL
    var request: URLRequest

    init(url: URL) {
        self.url = url
        request = .init(url: url)
    }
}

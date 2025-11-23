import Foundation
import Observation
import SomariKit

@Observable
final class FeedListViewModel {
    let source: FeedSource

    var list: [FeedArticle] = []

    @ObservationIgnored @Injected(FeedServiceKey.self) private var feedService

    init(source: FeedSource) {
        self.source = source
    }

    func fetch() async {
        do {
            let feed = try await feedService.fetch(url: source.url)
            list = feed.articles.map(FeedArticle.init)
        } catch {
            print(error)
        }
    }
}

extension FeedArticle {
    init(_ article: SomariKit.Article) {
        self.init(
            id: article.link.absoluteString,
            title: article.title ?? "<empty>",
            link: article.link,
            image: nil,
        )
    }
}

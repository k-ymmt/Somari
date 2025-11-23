import Foundation
import SomariKit
import FeedKit

public final class FeedKitService: FeedService {
    public init() {
    }

    public func fetch(url: URL) async throws -> SomariKit.Feed {
        let feed = try await FeedKit.Feed(url: url)

        return switch feed {
        case .atom(let atom):
            SomariKit.Feed(atom)
        case .rss(let rss):
            SomariKit.Feed(rss)
        case .json(let json):
            SomariKit.Feed(json)
        }
    }
}

private extension SomariKit.Feed {
    init(_ atom: FeedKit.AtomFeed) {
        self.init(
            title: atom.title?.text,
            link: atom.links?.first?.attributes?.href.flatMap(URL.init(string:)),
            articles: atom.entries?.compactMap(SomariKit.Article.init) ?? []
        )
    }
}

private extension SomariKit.Article {
    init?(_ entry: FeedKit.AtomFeedEntry) {
        guard let link = entry.links?
            .first(where: { $0.attributes?.rel == "alternate" &&  $0.attributes?.href != nil })?
            .attributes?.href
            .flatMap(URL.init(string:))
        else {
            return nil
        }
        self.init(
            id: entry.id,
            title: entry.title,
            link: link,
        )
    }
}

private extension SomariKit.Feed {
    init(_ rss: FeedKit.RSSFeed) {
        let channel = rss.channel
        self.init(
            title: channel?.title,
            link: channel?.link.flatMap(URL.init(string:)),
            articles: channel?.items?.compactMap(SomariKit.Article.init) ?? []
        )
    }
}

private extension SomariKit.Article {
    init?(_ item: FeedKit.RSSFeedItem) {
        guard
            let linkString = item.link,
            let link = URL(string: linkString)
        else {
            return nil
        }
        self.init(
            id: item.guid?.text,
            title: item.title,
            link: link
        )
    }
}

private extension SomariKit.Feed {
    init(_ json: FeedKit.JSONFeed) {
        self.init(
            title: json.title,
            link: json.feedURL.flatMap(URL.init(string:)),
            articles: json.items?.compactMap(SomariKit.Article.init) ?? []
        )
    }
}

private extension SomariKit.Article {
    init?(_ item: FeedKit.JSONFeedItem) {
        guard let linkString = item.url,
              let link = URL(string: linkString)
        else {
            return nil
        }
        self.init(
            id: item.id,
            title: item.title,
            link: link,
        )
    }
}

public extension FeedServiceKey {
    @_dynamicReplacement(for: defaultValue)
    static var implementDefaultValue: any FeedService {
        FeedKitService()
    }
}

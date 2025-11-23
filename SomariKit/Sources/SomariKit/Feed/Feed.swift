import Foundation

public struct Feed: Sendable {
    public let title: String?
    public let link: URL?
    public let articles: [Article]

    public init(title: String?, link: URL?, articles: [Article]) {
        self.title = title
        self.link = link
        self.articles = articles
    }
}

public struct Article: Sendable {
    public let id: String?
    public let title: String?
    public let link: URL

    public init(id: String?, title: String?, link: URL) {
        self.id = id
        self.title = title
        self.link = link
    }
}

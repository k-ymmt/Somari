import Foundation

struct FeedArticle: Identifiable, Hashable {
    let id: String
    let title: String
    let link: URL
    let image: URL?
}

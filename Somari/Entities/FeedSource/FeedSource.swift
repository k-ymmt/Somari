import Foundation

struct FeedSource: Hashable, Identifiable {
    let id: ModelIdentifier
    let url: URL
    let icon: URL?
    let name: String

    init(id: ModelIdentifier = .init(), url: URL, icon: URL?, name: String) {
        self.id = id
        self.url = url
        self.icon = icon
        self.name = name
    }
}

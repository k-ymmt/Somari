import Foundation
import SwiftData

@Model
final class FeedSourceEntity {
    @Attribute(.unique)
    var url: URL
    var icon: URL?
    var name: String

    init(url: URL, icon: URL?, name: String) {
        self.url = url
        self.icon = icon
        self.name = name
    }
}

extension FeedSourceEntity: EntityConvertible {
    convenience init(_ entity: FeedSource) {
        self.init(url: entity.url, icon: entity.icon, name: entity.name)
    }

    func entity() -> FeedSource {
        FeedSource(id: .init(id: id), url: url, icon: icon, name: name)
    }

    func update(from entity: FeedSource) {
        url = entity.url
        icon = entity.icon
        name = entity.name
    }
}

extension FeedSourceEntity: CustomStringConvertible {
    var description: String {
        "name: \(name), url: \(url.absoluteString), icon: \(icon?.absoluteString ?? "<nil>")"
    }
}

extension FeedSource: ModelConvertible {
    typealias ModelType = FeedSourceEntity
}

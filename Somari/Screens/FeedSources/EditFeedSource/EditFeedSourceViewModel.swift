import Foundation
import Observation

@Observable
final class EditFeedSourceViewModel {
    private let source: FeedSource
    var name: String

    init(source: FeedSource) {
        self.source = source
        name = source.name
    }
}

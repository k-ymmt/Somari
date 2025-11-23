import Foundation
import Observation
import SomariKit

@Observable
final class AddSourceViewModel {
    enum Error: Swift.Error {
        case invalidFeedURL
    }
    var feedURL: String = ""
    var error: Error?
    var completed: Bool = false

    @ObservationIgnored @Injected(FeedServiceKey.self) private var feedService
    @ObservationIgnored @Injected(DatabaseKey.self) private var database
    private var cancellables: Set<AnyCancellable> = []

    func addSource() {
        guard let url = URL(string: feedURL) else {
            self.error = .invalidFeedURL
            return
        }

        Task { @MainActor in
            do {
                // check valid feed url
                let feed = try await feedService.fetch(url: url)

                try await database.insert(FeedSource(url: url, icon: nil, name: feed.title ?? feedURL))
                completed = true
            } catch {
                self.error = .invalidFeedURL
            }
        }
        .store(in: &cancellables)
    }
}

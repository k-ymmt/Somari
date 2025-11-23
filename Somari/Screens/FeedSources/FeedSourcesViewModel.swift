import Foundation
import Observation
import SomariKit

@Observable
final class FeedSourcesViewModel {
    var sources: [FeedSource] = []
    private var cancellables: Set<AnyCancellable> = []

    @ObservationIgnored @Injected(DatabaseKey.self) private var database

    init() {
    }

    func fetch() async {
        for await _ in database.subscribeChangedNotification(of: FeedSource.self, actionForFirstTime: true) {
            do {
                self.sources = try await database.load()
                print("source loaded")
            } catch {
                print("load failed")
            }
        }
    }

    func deleteSource(_ source: FeedSource) {
        Task {
            do {
                try await database.delete(source)
            } catch {
                print(error)
            }
        }
    }
}

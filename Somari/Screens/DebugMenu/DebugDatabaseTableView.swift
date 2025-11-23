import SomariKit
import SwiftUI
import Observation
import SwiftData

struct DebugDatabaseTable: Identifiable {
    var id: String {
        name
    }
    var name: String {
        String(describing: type)
    }
    let type: Any.Type
}

@Observable
final class DebugDatabaseTableViewModel {
    @ObservationIgnored @Injected(DatabaseKey.self) private var database

    var entities: [String] = []

    init() {
    }

    func delete(_ indexSet: IndexSet) {
    }
}

struct DebugDatabaseTableView: View {
    @State private var viewModel: DebugDatabaseTableViewModel = .init()

    var body: some View {
        List {
            ListItem(FeedSourceEntity.self)
        }
        .navigationTitle("Tables")
        .toolbarTitleDisplayMode(.inline)
    }
}

private extension DebugDatabaseTableView {
    func ListItem<Entity: PersistentModel>(_ type: Entity.Type = Entity.self) -> some View {
        NavigationLink(String(describing: type)) {
            DebugDatabaseTableRowsView(of: type)
        }
    }
}

#Preview {
    NavigationView {
        DebugDatabaseTableView()
    }
}

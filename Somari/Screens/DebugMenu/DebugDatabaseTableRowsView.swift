import SomariKit
import SwiftUI
import SwiftData

@Observable
final class DebugDatabaseTableRowsViewModel<Entity: PersistentModel> {
    @ObservationIgnored @Injected(DatabaseKey.self) private var database

    let tableType: Entity.Type
    var rows: [Entity] = []

    init(tableType: Entity.Type) {
        self.tableType = tableType
    }

    func load() async {
        do {
            rows = try await database.load()
        } catch {
            print(error)
        }
    }

    func deleteRow(atOffsets offsets: IndexSet) {
        Task {
            do {
                try await database.delete(offsets.map { rows[$0] })
            } catch {
                print(error)
            }
        }
    }
}

struct DebugDatabaseTableRowsView<Entity: PersistentModel>: View {
    @State private var viewModel: DebugDatabaseTableRowsViewModel<Entity>

    init(of tableType: Entity.Type = Entity.self) {
        self._viewModel = .init(initialValue: DebugDatabaseTableRowsViewModel(tableType: tableType))
    }

    var body: some View {
        List {
            ForEach($viewModel.rows, id: \.id) { row in
                Text(String(describing: row.wrappedValue))
            }
            .onDelete { indexSet in
                viewModel.deleteRow(atOffsets: indexSet)
            }
        }
        List($viewModel.rows, id: \.self) { row in
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    DebugDatabaseTableRowsView(of: FeedSourceEntity.self)
}

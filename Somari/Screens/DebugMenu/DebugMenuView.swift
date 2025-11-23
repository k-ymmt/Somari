import SwiftUI

struct DebugMenuView: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink("Show Database") {
                    DebugDatabaseTableView()
                }
            }
        }
    }
}

import Foundation
import SwiftUI

struct EditFeedSourceView: View {
    @State private var viewModel: EditFeedSourceViewModel

    init(viewModel: EditFeedSourceViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }

    init(source: FeedSource) {
        self.init(viewModel: .init(source: source))
    }

    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $viewModel.name)
            }
            Spacer()

            Button {
            } label: {

            }
        }
    }
}

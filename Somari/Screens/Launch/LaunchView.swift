import Foundation
import SwiftUI

struct LaunchView: View {
    @State private var viewModel: LaunchViewModel

    init(viewModel: LaunchViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    init(completed: @escaping () -> Void) {
        self.init(viewModel: .init(completed: completed))
    }

    var body: some View {
        ProgressView()
            .scaleEffect(2)
    }
}

#Preview {
    LaunchView {
    }
}

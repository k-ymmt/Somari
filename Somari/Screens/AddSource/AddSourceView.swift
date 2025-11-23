import SwiftUI

struct AddSourceView: View {
    @State private var viewModel: AddSourceViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusState

    init(viewModel: AddSourceViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        TextField(
                            "Feed URL",
                            text: $viewModel.feedURL,
                            prompt: Text(verbatim: "https://example.com/feed.atom"),
                        )
                        .focused($focusState)
                    }
                }

                VStack {
                    Spacer()
                    Button{
                        viewModel.addSource()
                    } label: {
                        Text("Add")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.feedURL.isEmpty)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Add Source")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onChange(of: viewModel.completed) {
                if viewModel.completed {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = AddSourceViewModel()
    AddSourceView(viewModel: viewModel)
}

import SwiftUI
import UIComponents
import SomariKit
import Kingfisher

struct FeedSourcesView: View {
    enum Path: Hashable {
        case feedList(FeedSource)
    }
    @Environment(PageRouter.self) private var router: PageRouter
    @State private var viewModel: FeedSourcesViewModel
    @State private var path: NavigationPath = .init()
    @State private var isPresentingAddSource: Bool = false
    @State private var isPresentingEditSource: Bool = false

    init(viewModel: FeedSourcesViewModel) {
        self.viewModel = viewModel
    }

    init() {
        self.init(viewModel: .init())
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            VStack {
                List {
                    Section {
                        ListItem(icon: .static("text.document"), name: "All") {
                        }
                    }
                    Section {
                        ForEach(viewModel.sources) { source in
                            ListItem(icon: .url(source.icon), name: source.name) {
                                router.go(to: Path.feedList(source))
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                //                            Button {
                                //                            } label: {
                                //                                Image(systemName: "slider.horizontal.3")
                                //                            }
                                //                            .tint(.blue)
                                Button {
                                    viewModel.deleteSource(source)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sources")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSource = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Path.self) { path in
                switch path {
                case .feedList(let source):
                    FeedListView(source: source)
                }
            }
            .sheet(isPresented: $isPresentingAddSource) {
                AddSourceView(viewModel: .init())
            }
            .task {
                await viewModel.fetch()
            }
        }
    }
}

private extension FeedSourcesView {
    enum ListItemIconType {
        case `static`(String)
        case url(URL?)
    }

    @ViewBuilder
    func Icon(_ type: ListItemIconType) -> some View {
        switch type {
        case .static(let systemName):
            Image(systemName: systemName)
                .foregroundStyle(.foreground)
        case .url(let url):
            KFImage(url)
        }
    }

    @ViewBuilder
    func ListItem(icon: ListItemIconType, name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Icon(icon)
                    .frame(width: 20, height: 20)
                Text(name)
                    .foregroundStyle(.black.opacity(0.8))
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                ListDisclosureView()
            }
            .padding(.all, 4)
        }
    }
}


#Preview {
    @Previewable @State var viewModel = FeedSourcesViewModel()

    viewModel.sources = [
        .init(
            url: #URL("https://example.com/foo"),
            icon: #URL("https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico"),
            name: "foo"
        ),
        .init(
            url: #URL("https://example.com/bar"),
            icon: #URL("https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico"),
            name: "bar"
        ),
    ]

    return FeedSourcesView(viewModel: viewModel)
        .environment(PageRouter())
}

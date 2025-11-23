import SwiftUI
import SomariKit
import UIComponents
import Kingfisher

struct FeedListView: View {
    enum Path: Hashable {
        case article(FeedArticle)
    }
    @Environment(PageRouter.self) var router
    @State var viewModel: FeedListViewModel

    init(source: FeedSource) {
        self.init(viewModel: .init(source: source))
    }

    init(viewModel: FeedListViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.list) { article in
            Button {
                router.go(to: Path.article(article))
            } label: {
                HStack {
                    VStack(spacing: 0) {
                        Text(article.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4)
                        Text(viewModel.source.name)
                            .font(.system(size: 14))
                            .foregroundStyle(.black.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let image = article.image {
                        KFImage(image)
                    }
                    Spacer()
                    ListDisclosureView()
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                .padding(.horizontal, 16)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.source.name)
        .navigationDestination(for: Path.self) { path in
            switch path {
            case .article(let article):
                ArticleView(url: article.link)
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FeedListViewModel(source: .init(
        url: #URL("https://example.com"),
        icon: #URL("https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico"),
        name: "Example"
    ))

    @Previewable @State var router = PageRouter()
    return NavigationStack(path: $router.path) {
        FeedListView(viewModel: viewModel)
    }
    .environment(router)
}

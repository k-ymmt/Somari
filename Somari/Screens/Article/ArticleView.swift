import Foundation
import SwiftUI
import WebKit
import SomariKit

struct ArticleView: View {
    @State private var webPage: WebPage = .init()

    @State private var viewModel: ArticleViewModel
    @State private var canBack: Bool = false
    @State private var showShareLink: Bool = false
    @Environment(\.dismiss) var dismiss

    init(viewModel: ArticleViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }

    init(url: URL) {
        self.init(viewModel: .init(url: url))
    }

    var body: some View {
        WebView(webPage)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        showShareLink = true
                        ShareLink(item: viewModel.url)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button {
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    Button {
                    } label: {
                        Image(systemName: "safari")
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                webPage.load(viewModel.request)
            }
            .onChange(of: viewModel.request) {
                webPage.load(viewModel.request)
            }
            .onChange(of: webPage.backForwardList) {
                canBack = !webPage.backForwardList.backList.isEmpty
            }
    }
}

#Preview {
    ArticleView(url: #URL("https://zenn.dev"))
}

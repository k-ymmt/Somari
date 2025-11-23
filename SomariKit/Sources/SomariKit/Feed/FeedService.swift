import Foundation

public protocol FeedService: Sendable {
    func fetch(url: URL) async throws -> Feed
}

public struct DummyFeedService: FeedService {
    @Mutex public var fetchResult: Feed = .init(
        title: "Example",
        link: #URL("https://example.com"),
        articles: [
            .init(#"なぜ "use client" ディレクティブは優れた API なのか"#),
            .init("コミュニティへの関わり方②コミュニティアンバサダーという選択肢"),
            .init("コミュニティへの関わり方①あなたに合った参加スタイルを見つけよう"),
            .init("第4回：NumPy配列の結合"),
            .init("tldraw × AIエージェント：Agent starter kitを触りながら仕組みを追う"),
            .init("Amazon Bedrock AgentCore Runtimeで zip ファイルを直接アップロードでデプロイしてみた"),
            .init("自宅のRTX3060で小さなLLMを自作してみた"),
        ]
    )
    public func fetch(url: URL) async throws -> Feed {
        fetchResult
    }

    public init(fetchResult: Feed? = nil) {
        if let fetchResult {
            self.fetchResult = fetchResult
        }
    }
}

public struct FeedServiceKey: ContainerKey {
    public static dynamic var defaultValue: any FeedService {
        fatalError("Unimplemented FeedService")
    }

    public static var testValue: any FeedService {
        DummyFeedService()
    }
}

private extension Article {
    init(_ title: String) {
        self.init(
            id: title,
            title: title,
            link: #URL("https://example.com"),
        )
    }
}

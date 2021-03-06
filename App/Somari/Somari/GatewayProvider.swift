//
//  GatewayProvider.swift
//  Somari
//
//  Created by Kazuki Yamamoto on 2019/10/13.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import UIKit
import SomariCore
import Account
import Feeds
import Addition

class GatewayProvider {
    private let window: UIWindow

    let main: MainGateway
    let login: AccountGateway
    let feeds: FeedsGateway
    let addition: AdditionGateway

    init(window: UIWindow, resolver: DependencyResolver) {
        self.main = MainGateway()
        self.login = AccountGateway(dependency: .init(
            accountService: resolver.accountService
        ))
        self.feeds = FeedsGateway(dependency: .init(
            feedService: resolver.feedService,
            storageService: resolver.storageService,
            accountService: resolver.accountService,
            feedItemCacheService: resolver.feedItemCacheService
        ))
        self.addition = AdditionGateway(dependency: .init(
            feedService: resolver.feedService,
            accountService: resolver.accountService,
            storageService: resolver.storageService
        ))
        self.window = window
        subscribeOutputs()
    }

    func launch() {
        let viewController = LaunchRouter.assembleModules(dependency: .init(), action: { _ in })
        window.rootViewController = viewController
        self.login.input(.startLoginStateListening)
    }

    private func subscribeOutputs() {
        self.main.output { [weak self] (output) in self?.mainGatewayOutputAction(output: output) }
        self.login.output { [weak self] (output) in self?.loginGatewayOutputAction(output: output) }
        self.feeds.output { [weak self] (output) in self?.feedsGatewayOutputAction(output: output) }
        self.addition.output { [weak self] (output) in self?.additionGatewayOutputAction(output: output) }
    }
}

// MARK: - MainGateway
private extension GatewayProvider {
    private func mainGatewayOutputAction(output: MainGateway.Output) {
        switch output {
        case .showMainTab(let viewController):
            self.window.rootViewController = viewController
        }
    }
}

// MARK: - LoginGateway
private extension GatewayProvider {
    private func loginGatewayOutputAction(output: AccountGateway.Output) {
        switch output {
        case .loginSuccess:
            self.main.input(.showMainTab)
            self.feeds.input(.showFeeds)
            self.addition.input(.showAdditionalFeed)
        case .loginFailure(let error):
            switch error {
            case .notLogin:
                login.input(.showLoginPage)
            case .loginFailed:
                login.input(.showLoginPage)
            case .unknown:
                break
            }
        case .showLoginPage(let viewController):
            window.rootViewController = UINavigationController(rootViewController: viewController)
        }
    }
}

// MARK: - FeedsGateway
private extension GatewayProvider {
    private func feedsGatewayOutputAction(output: FeedsGateway.Output) {
        switch output {
        case .showFeeds(let viewController):
            main.input(.setFeeds(viewController))
        case .gotoAdditionView:
            main.input(.switchTab(.addition))
        }
    }
}

// MARK: - AdditionGateway
private extension GatewayProvider {
    private func additionGatewayOutputAction(output: AdditionGateway.Output) {
        switch output {
        case .showAdditionalFeed(let viewController):
            main.input(.setAdditionalFeed(viewController))
        }
    }
}

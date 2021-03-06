//
//  MainGateway.swift
//  Somari
//
//  Created by Kazuki Yamamoto on 2019/10/13.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import UIKit
import SomariFoundation

class MainGateway: Gateway {
    enum Input {
        enum TabCategory: Int {
            case feeds = 0
            case addition = 1
        }
        case showMainTab
        case setFeeds(UIViewController)
        case setAdditionalFeed(UIViewController)
        case switchTab(TabCategory)
    }

    enum Output {
        case showMainTab(UIViewController)
    }

    private weak var mainTab: UITabBarController!
    private var outputAction: ((Output) -> Void)?

    private var showMainTab: Bool = false
    private var feedsViewController: UIViewController?
    private var additionalFeedViewController: UIViewController?

    required init(dependency: Void) {
    }

    func input(_ value: MainGateway.Input) {
        switch value {
        case .showMainTab:
            self.showMainTab = true
            showMainTabIfNeed()
        case .setFeeds(let viewController):
            self.feedsViewController = viewController
            showMainTabIfNeed()
        case .setAdditionalFeed(let viewController):
            self.additionalFeedViewController = viewController
            showMainTabIfNeed()
        case .switchTab(let category):
            mainTab.selectedIndex = category.rawValue
        }
    }

    func output(_ action: @escaping (MainGateway.Output) -> Void) {
        self.outputAction = action
    }

    func showMainTabIfNeed() {
        guard showMainTab,
            let feedsViewController = self.feedsViewController,
            let additionalFeedViewController = self.additionalFeedViewController else {
                return
        }

        let viewController = MainTabRouter.assembleModules(
            feedsViewController: feedsViewController,
            additionalFeedViewController: additionalFeedViewController
        )

        mainTab = viewController
        outputAction?(.showMainTab(viewController))
    }
}

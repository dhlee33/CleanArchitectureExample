//
//  GitHubSearchFlow.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxFlow
import Swinject

class GitHubSearchFlow: Flow {
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? GitHubSearchStep else { return .none }
        switch step {
        case .showSearchView:
            return showSearchView()
        case let .showDetail(url):
            return showDetail(url)
        }
    }
    
    private func showSearchView() -> FlowContributors {
        guard let usecase = container.resolve(GitHubSearchUseCase.self) else {
            return .none
        }
        let reactor = GitHubSearchViewReactor(gitHubSearchUseCase: usecase)

        let searchVC = GitHubSearchViewController(reactor: reactor)
        rootViewController.pushViewController(searchVC, animated: true)

        return .one(flowContributor: .contribute(withNextPresentable: searchVC, withNextStepper: reactor))
    }

    private func showDetail(_ url: URL) -> FlowContributors {
        let reactor = GitHubSearchDetailViewReactor(url: url)
        let detailVC = GitHubSearchDetailViewController(reactor: reactor)

        rootViewController.pushViewController(detailVC, animated: true)
        return .none
    }
}

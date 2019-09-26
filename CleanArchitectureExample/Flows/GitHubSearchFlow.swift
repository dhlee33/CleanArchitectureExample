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
    let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    var root: Presentable {
        return self.rootViewController
    }

    private lazy var rootViewController: UINavigationController = {
        let vc = UINavigationController()
        return vc
    }()

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
        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GitHubSearchViewController") as! GitHubSearchViewController
        rootViewController.pushViewController(searchVC, animated: true)
        guard let reactor = container.resolve(GitHubSearchViewReactor.self) else {
            return .none
        }
        searchVC.reactor = reactor

        return .one(flowContributor: .contribute(withNextPresentable: searchVC, withNextStepper: reactor))
    }

    private func showDetail(_ url: URL) -> FlowContributors {
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GitHubSearchDetailViewController") as! GitHubSearchDetailViewController
        let reactor = GitHubSearchDetailViewReactor(url: url)
        detailVC.reactor = reactor
        rootViewController.pushViewController(detailVC, animated: true)
        return .none
    }
}

//
//  GitHubSearchFlow.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxFlow

class GitHubSearchFlow: Flow {
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
        case let .showDetail(fullName):
            return showDetail(fullName)
        }
    }
    
    private func showSearchView() -> FlowContributors {
        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GitHubSearchViewController") as! GitHubSearchViewController
        rootViewController.pushViewController(searchVC, animated: true)
        guard let reactor = DefaultContainer.shared.resolve(GitHubSearchViewReactor.self) else {
            return .none
        }
        searchVC.reactor = reactor

        return .one(flowContributor: .contribute(withNextPresentable: searchVC, withNextStepper: reactor))
    }

    private func showDetail(_ fullName: String) -> FlowContributors {
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GitHubSearchDetailViewController") as! GitHubSearchDetailViewController
        let reactor = GitHubSearchDetailViewReactor(fullName: fullName)
        detailVC.reactor = reactor
        rootViewController.pushViewController(detailVC, animated: true)
        return .none
    }
}

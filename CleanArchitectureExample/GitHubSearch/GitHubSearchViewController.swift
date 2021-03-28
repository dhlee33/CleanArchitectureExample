//
//  GitHubSearchViewController.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 09/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//
import ReactorKit
import RxCocoa
import RxSwift
import Then
import SnapKit

class GitHubSearchViewController: UIViewController, View {
    private let tableView = UITableView().then {
        $0.register(GitHubSearchCell.self, forCellReuseIdentifier: GitHubSearchCell.reuseIdentifier)
    }
    private let activityIndicator = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
    }
    private let labelNoResult = UILabel().then {
        $0.text = "No Result"
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 24)
        $0.textAlignment = .center
    }
    private let searchController = UISearchController(searchResultsController: nil).then {
        $0.obscuresBackgroundDuringPresentation = false
    }

    var disposeBag = DisposeBag()

    init(reactor: GitHubSearchViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        navigationItem.title = "GitHub search"
        navigationItem.searchController = searchController

        view.addSubview(labelNoResult)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        labelNoResult.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bind(reactor: GitHubSearchViewReactor) {
        searchController.searchBar.rx.text
            .debounce(1, scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.repos }
            .do(onNext: { [weak self] repos in
                self?.tableView.isHidden = repos.isEmpty
            })
            .bind(to: tableView.rx.items(cellIdentifier: GitHubSearchCell.reuseIdentifier, cellType: GitHubSearchCell.self)) { index, item, cell in
                let reactor = GitHubSearchCellReactor(item: item)
                cell.reactor = reactor
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .do(onNext: { [weak self] loading in self?.labelNoResult.isHidden = loading })
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(GitHubSearchItem.self)
            .map { .showDetail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

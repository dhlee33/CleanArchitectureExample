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
import SafariServices

class GitHubSearchViewController: BaseViewController, StoryboardView {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelNoResult: UILabel!
    typealias Reactor = GitHubSearchViewReactor
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollIndicatorInsets.top = tableView.contentInset.top
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        reactor = DefaultContainer.shared.resolve(Reactor.self)

        activityIndicator.hidesWhenStopped = true
    }
    
    func bind(reactor: GitHubSearchViewReactor) {
        searchController.searchBar.rx.text
            .throttle(1, scheduler: MainScheduler.instance)
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
            .bind(to: tableView.rx.items) { tableView, Int, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "GitHubSearchCell") as! GitHubSearchCell
                let reactor = GitHubSearchCellReactor(item: item)
                cell.reactor = reactor
                return cell
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .do(onNext: { [weak self] loading in self?.labelNoResult.isHidden = loading })
            .bind(to: activityIndicator.rx.isAnimating)
        .disposed(by: disposeBag)
        
        reactor.error
            .map { ToastLabelReactor.Action.showToast($0) }
            .bind(to: errorToast.reactor!.action)
            .disposed(by: disposeBag)
        
        reactor.totalCount
            .map { ToastLabelReactor.Action.showToast("Total Count: \($0)") }
            .bind(to: infoToast.reactor!.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: false)
                let repo = reactor.currentState.repos[indexPath.row]
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let viewController = SFSafariViewController(url: url)
                self.searchController.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

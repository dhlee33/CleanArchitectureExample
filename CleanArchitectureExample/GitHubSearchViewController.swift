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

class GitHubSearchViewController: UIViewController, StoryboardView {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelNoResult: UILabel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollIndicatorInsets.top = tableView.contentInset.top
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        reactor = GitHubSearchViewReactor()

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
            .do(onNext: { [weak self] repose in
                self?.tableView.isHidden = repose.isEmpty
            })
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { indexPath, repo, cell in
                cell.textLabel?.text = repo.fullName
                switch repo.star {
                case 1000..<10000:
                    cell.detailTextLabel?.text = "✰"
                case 10000...:
                    cell.detailTextLabel?.text = "✰✰"
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .do(onNext: { [weak self] loading in self?.labelNoResult.isHidden = loading })
            .bind(to: activityIndicator.rx.isAnimating)
        .disposed(by: disposeBag)
        
        reactor.error.throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
            self?.showErrorToast(message: error)
        }).disposed(by: disposeBag)
        
        reactor.totalCount.throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
            self?.showToast(message: "Total Count: \(count)")
        }).disposed(by: disposeBag)
        
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

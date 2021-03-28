//
//  GitHubSearchViewReactor.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 09/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift
import RxFlow

final class GitHubSearchViewReactor: Reactor, Stepper {
    let steps = PublishRelay<Step>()
    private let gitHubSearchUseCase: GitHubSearchUseCase
    
    init(gitHubSearchUseCase: GitHubSearchUseCase) {
        self.gitHubSearchUseCase = gitHubSearchUseCase
        self.initialState = State(
            query: nil,
            repos: [],
            nextPage: nil,
            loadingQueue: 0
        )
    }

    enum Action {
        case updateQuery(String?)
        case loadNextPage
        case showDetail(GitHubSearchItem)
    }
    
    enum Mutation {
        case setQuery(String?)
        case setRepos([GitHubSearchItem], nextPage: Int?)
        case appendRepos([GitHubSearchItem], nextPage: Int?)
        case setLoading(Bool)
    }
    
    struct State {
        var query: String?
        var repos: [GitHubSearchItem]
        var nextPage: Int?
        var loadingQueue: Int
        var isLoading: Bool {
            return loadingQueue > 0
        }
    }
    
    let initialState: State
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateQuery(query):
            return Observable.concat([
                .just(.setQuery(query)),
                search(query: query, page: 1, loadMore: false)
            ])
        case .loadNextPage:
            guard !currentState.isLoading else { return Observable.empty() }
            guard let page = currentState.nextPage else { return Observable.empty() }
            return
                search(query: currentState.query, page: page, loadMore: true)
        case let .showDetail(item):
            let fullName = item.fullName
            guard let url = gitHubSearchUseCase.getRepoUrl(fullName: fullName) else {
                return .empty()
            }
            steps.accept(GitHubSearchStep.showDetail(url: url))
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setQuery(query):
            newState.query = query
            
        case let .setRepos(repos, nextPage):
            newState.repos = repos
            newState.nextPage = nextPage
            
        case let .appendRepos(repos, nextPage):
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
            
        case let .setLoading(isLoading):
            if isLoading {
                newState.loadingQueue += 1
            } else {
                newState.loadingQueue -= 1
            }
            newState.loadingQueue = max(0, newState.loadingQueue)
        }
        return newState
    }
    
    private func search(query: String?, page: Int, loadMore: Bool) -> Observable<Mutation> {
        guard let query = query, !query.isEmpty else {
            return .just(.setRepos([], nextPage: nil))
        }
        return Observable.concat([
            .just(.setLoading(true)),
            gitHubSearchUseCase.search(query: query, page: page)
                .asObservable()
                .catchErrorJustReturn(GitHubSearch(items: [], totalCount: 0))
                .map { data in
                    let nextPage: Int? = data.items.isEmpty ? nil: page + 1
                    if loadMore {
                        return .appendRepos(data.items, nextPage: nextPage)
                    } else {
                        return .setRepos(data.items, nextPage: nextPage)
                    }
                },
            .just(.setLoading(false)),
        ])
    }
}


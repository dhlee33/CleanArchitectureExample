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
    let gitHubSearchUseCase: GitHubSearchUseCase
    
    init(gitHubSearchUseCase: GitHubSearchUseCase) {
        self.gitHubSearchUseCase = gitHubSearchUseCase
    }
    
    let error = PublishRelay<String>()
    let totalCount = PublishRelay<Int>()

    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(String?)
        case setRepos([GitHubSearchItem], totalCount: Int?, nextPage: Int?)
        case appendRepos([GitHubSearchItem], nextPage: Int?)
        case setLoading(Bool)
        case setError(String?)
    }
    
    struct State {
        var query: String?
        var repos: [GitHubSearchItem] = []
        var nextPage: Int?
        var loadingQueue: Int = 0
        var totalCount: Int?
        var error: String?
        var isLoading: Bool {
            return loadingQueue > 0
        }
    }
    
    let initialState = State()
    
    func transform(state: Observable<State>) -> Observable<State> {
        return state.do(onNext: { [weak self] state in
            guard !state.isLoading else { return }
            if let error = state.error {
                self?.error.accept(error)
            }
            if let totalCount = state.totalCount {
                self?.totalCount.accept(totalCount)
            }
        })
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateQuery(query):
            return Observable.concat([.just(.setQuery(query)), self.search(query: query, page: 1, loadMore: false)])
        case .loadNextPage:
            guard !self.currentState.isLoading else { return Observable.empty() }
            guard let page = self.currentState.nextPage else { return Observable.empty() }
            return self.search(query: self.currentState.query, page: page, loadMore: true)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case let .setQuery(query):
            newState.query = query
            newState.totalCount = nil
            
        case let .setRepos(repos, totalCount, nextPage):
            newState.repos = repos
            newState.nextPage = nextPage
            newState.totalCount = totalCount
            
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
            newState.totalCount = nil
            
        case let .setError(error):
            newState.error = error
        }
        return newState
    }
    
    private func search(query: String?, page: Int, loadMore: Bool) -> Observable<Mutation> {
        guard let query = query, !query.isEmpty else {
            return .just(.setRepos([], totalCount: nil, nextPage: nil))
        }
        return gitHubSearchUseCase.search(query: query, page: page)
            .flatMap { resource -> Observable<Mutation> in
                switch resource {
                case let .Success(data):
                    let nextPage: Int? = data.items.isEmpty ? nil: page + 1
                    if loadMore {
                        return .concat([
                            .just(.setLoading(false)),
                            .just(.appendRepos(data.items, nextPage: nextPage))
                            ])
                    } else {
                        return .concat([
                            .just(.setLoading(false)),
                            .just(.setRepos(data.items, totalCount: data.totalCount, nextPage: nextPage))
                            ])
                    }
                case .Loading:
                    return .just(.setLoading(true))
                case .Failure:
                    return .concat([
                        .just(.setLoading(false)),
                        .just(.setError("Error Occurred"))
                        ])
                }
        }
    }
    
    func showDetail(index: Int) {
        let fullName = currentState.repos[index].fullName
        guard let url = gitHubSearchUseCase.getRepoUrl(fullName: fullName) else {
            error.accept("Invalid URL")
            return
        }
        self.steps.accept(GitHubSearchStep.showDetail(url: url))
    }
}


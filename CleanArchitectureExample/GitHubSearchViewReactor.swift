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

final class GitHubSearchViewReactor: Reactor {
    let gitHubSearchUseCase: GitHubSearchUseCase
    
    var totalCount = PublishRelay<Int>()
    var error = PublishRelay<String>()
    
    init(gitHubSearchUseCase: GitHubSearchUseCase) {
        self.gitHubSearchUseCase = gitHubSearchUseCase
    }

    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(String?)
        case setRepos([GitHubSearchItem], nextPage: Int?)
        case appendRepos([GitHubSearchItem], nextPage: Int?)
        case setLoading(Bool)
    }
    
    struct State {
        var query: String?
        var repos: [GitHubSearchItem] = []
        var nextPage: Int?
        var isLoading: Bool = false
    }
    
    let initialState = State()
    
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
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState
            
        case let .setRepos(repos, nextPage):
            var newState = state
            newState.isLoading = false
            newState.repos = repos
            newState.nextPage = nextPage
            return newState
            
        case let .appendRepos(repos, nextPage):
            var newState = state
            newState.isLoading = false
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
            return newState
            
        case let .setLoading(isLoadingNextPage):
            var newState = state
            newState.isLoading = isLoadingNextPage
            return newState
        }
    }
    
    private func search(query: String?, page: Int, loadMore: Bool) -> Observable<Mutation> {
        guard let query = query, !query.isEmpty else {
            return .just(.setRepos([], nextPage: nil))
        }
        return gitHubSearchUseCase.search(query: query, page: page)
            .flatMap { [weak self] resource -> Observable<Mutation> in
                switch resource {
                case let .Success(data):
                    let nextPage: Int? = data.items.isEmpty ? nil: page + 1
                    if loadMore {
                        return .just(.appendRepos(data.items, nextPage: nextPage))
                    } else {
                        self?.totalCount.accept(data.totalCount)
                        return .just(.setRepos(data.items, nextPage: nextPage))
                    }
                case .Loading:
                    return .just(.setLoading(true))
                case .Failure:
                    self?.error.accept("Error occurred")
                    return .just(.setLoading(false))
                }
        }
    }
}


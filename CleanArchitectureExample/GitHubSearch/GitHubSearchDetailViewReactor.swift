//
//  GitHubSearchDetailViewReactor.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit
import RxFlow
import RxSwift

class GitHubSearchDetailViewReactor: Reactor {
    enum Action {
        case setLoading(Bool)
    }

    enum Mutation {
        case setLoading(Bool)
    }

    struct State {
        var url: URL
        var loading: Bool
    }
    
    let initialState: State
    
    init(url: URL) {
        self.initialState = State(url: url, loading: false)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setLoading(loading):
            return .just(.setLoading(loading))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(loading):
            newState.loading = loading
        }
        return newState
    }
}

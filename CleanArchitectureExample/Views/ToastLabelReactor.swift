//
//  ToastViewReactor.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit
import RxSwift

class ToastLabelReactor: Reactor {
    struct State {
        var text: String?
    }
    let initialState = State()
    
    enum Action {
        case showToast(String)
    }
    
    enum Mutation {
        case setText(String)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .showToast(text):
            return .just(.setText(text))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setText(text):
            newState.text = text
        }
        return newState
    }
}

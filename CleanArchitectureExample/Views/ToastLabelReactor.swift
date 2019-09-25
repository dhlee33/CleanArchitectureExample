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
        var backgroundColor = UIColor.black
    }
    let initialState = State()
    
    enum Action {
        case info(String)
        case error(String)
    }
    
    enum Mutation {
        case setText(String, backgroundColor: UIColor)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .info(text):
            return .just(.setText(text, backgroundColor: .black))
        case let .error(text):
            return .just(.setText(text, backgroundColor: .red))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setText(text, backgroundColor):
            newState.text = text
            newState.backgroundColor = backgroundColor
        }
        return newState
    }
}

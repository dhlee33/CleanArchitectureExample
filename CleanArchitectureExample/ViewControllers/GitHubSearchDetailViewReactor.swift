//
//  GitHubSearchDetailViewReactor.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit
import RxFlow
import RxCocoa

class GitHubSearchDetailViewReactor: Reactor {
    typealias Action = NoAction
    struct State {
        var url: URL
    }
    
    let initialState: State
    
    init(url: URL) {
        self.initialState = State(url: url)
    }
}

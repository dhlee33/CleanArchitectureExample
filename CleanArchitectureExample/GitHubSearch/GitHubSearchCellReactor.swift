//
//  RepoCellReactor.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit

final class GitHubSearchCellReactor: Reactor {
    typealias Action = NoAction
    struct State {
        var title: String
        var star: String
    }
    
    let initialState: State
    
    init(item: GitHubSearchItem) {
        var star = ""
        switch item.star {
        case 1000..<10000:
            star = "✰"
        case 10000...:
            star = "✰✰"
        default: break
        }
        self.initialState = State(title: item.fullName, star: star)
    }
}

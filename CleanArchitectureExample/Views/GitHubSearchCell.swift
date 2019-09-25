//
//  GitHubSearchCell.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import ReactorKit
import RxSwift

final class GitHubSearchCell: UITableViewCell, View {
    var disposeBag = DisposeBag()
    
    typealias Reactor = GitHubSearchCellReactor
    
    func bind(reactor: Reactor) {
        self.textLabel?.text = reactor.currentState.title
        self.detailTextLabel?.text = reactor.currentState.star
    }
}

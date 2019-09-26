//
//  GItHubSearchDetailViewController.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import WebKit

class GitHubSearchDetailViewController: BaseViewController, StoryboardView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var webView: WKWebView!
    typealias Reactor = GitHubSearchDetailViewReactor
    
    func bind(reactor: Reactor) {
        webView.load(URLRequest(url: reactor.currentState.url))
    }
}

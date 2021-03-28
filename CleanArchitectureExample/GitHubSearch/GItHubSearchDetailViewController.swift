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

class GitHubSearchDetailViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    private lazy var webView = WKWebView().then {
        $0.navigationDelegate = self
    }
    private let activityIndicator = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
    }

    init(reactor: GitHubSearchDetailViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        view.addSubview(webView)
        view.addSubview(activityIndicator)

        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bind(reactor: GitHubSearchDetailViewReactor) {
        webView.load(URLRequest(url: reactor.initialState.url))

        reactor.state.map { $0.loading }
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}

extension GitHubSearchDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reactor?.action.onNext(.setLoading(true))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        reactor?.action.onNext(.setLoading(false))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        reactor?.action.onNext(.setLoading(false))
    }
}

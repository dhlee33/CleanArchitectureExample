//
//  GitHubSearchUseCase.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift

protocol GitHubSearchUseCase {
    func search(query: String, page: Int) -> Single<GitHubSearch>
    func getRepoUrl(fullName: String) -> URL?
}

final class DefaultGitHubSearchUseCase: GitHubSearchUseCase {
    private let requestManager: RequestManager
    private let toastManager: ToastManager
    
    init(
        requestManager: RequestManager,
        toastManager: ToastManager
    ) {
        self.toastManager = toastManager
        self.requestManager = requestManager
    }
    
    func search(query: String, page: Int) -> Single<GitHubSearch> {
        let parameters: [String: Any] = ["q": query, "page": page]
        return requestManager.get("https://api.github.com/search/repositories", parameters: parameters, responseType: GitHubSearch.self)
            .do(onSuccess: { [toastManager] data in
                guard page == 1 else { return }
                toastManager.showToast(.success("Total Count: \(data.totalCount)"))
            }, onError: { [toastManager] _ in
                toastManager.showToast(.generalError)
            })
    }

    func getRepoUrl(fullName: String) -> URL? {
        return URL(string: "https://github.com/\(fullName)")
    }
}

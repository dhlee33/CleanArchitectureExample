//
//  GitHubSearchUseCase.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift

protocol GitHubSearchUseCase {
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>>
}

final class DefaultGitHubSearchUseCase: GitHubSearchUseCase {
    let webApi: WebApi
    
    init(webApi: WebApi) {
        self.webApi = webApi
    }
    
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>> {
        return webApi.search(query: query, page: page)
    }
}

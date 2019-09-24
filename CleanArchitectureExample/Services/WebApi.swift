//
//  WebApi.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift

protocol WebApi {
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>>
}

struct DefaultWebApi: WebApi {
    let network: Network
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>> {
        return network.get("https://api.github.com/search/repositories?q=\(query)&page=\(page)", responseType: GitHubSearch.self)
    }
}

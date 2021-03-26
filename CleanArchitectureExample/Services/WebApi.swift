//
//  WebApi.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift

protocol WebApi: class {
    func search(query: String, page: Int) -> Single<GitHubSearch>
}

final class DefaultWebApi: WebApi {
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func search(query: String, page: Int) -> Single<GitHubSearch> {
        let parameters: [String: Any] = ["q": query, "page": page]
        return network.get("https://api.github.com/search/repositories", parameters: parameters, responseType: GitHubSearch.self)
    }
}

//
//  MockGitHubSearchUseCase.swift
//  CleanArchitectureExampleTests
//
//  Created by 이동현 on 2019/09/29.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift
@testable import CleanArchitectureExample

final class MockGitHubSearchUseCase: GitHubSearchUseCase {
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>> {
        var items: [GitHubSearchItem] = []
        for i in 0..<page * 3 {
            items.append(GitHubSearchItem(fullName: "\(query) test item\(i), page: \(i / 3)", star: 999 * i))
        }
        let resource = GitHubSearch(items: items, totalCount: page * 3)
        print("$$$", resource.items.count, resource.totalCount)
        return .just(.Success(resource))
    }
    
    func getRepoUrl(fullName: String) -> URL? {
        return URL(string: fullName)
    }
}

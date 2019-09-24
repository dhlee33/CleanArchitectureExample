//
//  UseCaseProvider.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//
protocol UseCaseProvider {
    func getGitHubSearchUseCase() -> GitHubSearchUseCase
}

class DefaultUseCaseProvider: UseCaseProvider {
    func getGitHubSearchUseCase() -> GitHubSearchUseCase {
        return DefaultGitHubSearchUseCase(webApi: DefaultWebApi(network: DefaultNetwork()))
    }
}

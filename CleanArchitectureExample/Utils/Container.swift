//
//  Container.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

class DefaultContainer {
    static var shared: Container = {
        let container = Container()
        container.autoregister(Network.self, initializer: DefaultNetwork.init)
        container.autoregister(WebApi.self, initializer: DefaultWebApi.init)
        container.autoregister(GitHubSearchUseCase.self, initializer: DefaultGitHubSearchUseCase.init)
        container.autoregister(GitHubSearchViewReactor.self, initializer: GitHubSearchViewReactor.init)
        return container
    } ()
}

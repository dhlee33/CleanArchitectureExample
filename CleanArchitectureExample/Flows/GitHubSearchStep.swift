//
//  GitHubSearchStep.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 26/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxFlow

enum GitHubSearchStep: Step {
    case showSearchView
    case showDetail(url: URL)
}

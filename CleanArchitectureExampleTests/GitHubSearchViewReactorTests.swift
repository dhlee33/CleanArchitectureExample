//
//  CleanArchitectureExampleTests.swift
//  CleanArchitectureExampleTests
//
//  Created by 이동현 on 2019/09/29.
//  Copyright © 2019 이동현. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import CleanArchitectureExample


class GitHubSearchViewReactorTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func searchTest() {
        let scheduler = TestScheduler(initialClock: 0)
        let gitHubSearchUseCase: GitHubSearchUseCase = MockGitHubSearchUseCase()
        let reactor = GitHubSearchViewReactor(gitHubSearchUseCase: gitHubSearchUseCase)
        
        let observable: TestableObservable<GitHubSearchViewReactor.Action> = scheduler.createHotObservable([
          next(100, GitHubSearchViewReactor.Action.updateQuery("test")),
          next(300, GitHubSearchViewReactor.Action.loadNextPage),
          next(400, GitHubSearchViewReactor.Action.loadNextPage),
          completed(500)
        ])
        
        observable
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
                        
        let res = scheduler.start() {
            reactor.state
                .map { $0.repos.count }
            .distinctUntilChanged()
        }
        
        let correctMessages = [
          next(200, 3),
          next(300, 9),
          next(400, 18)
        ]
                
        XCTAssertEqual(res.events, correctMessages)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}

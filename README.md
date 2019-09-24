# CleanArchitectureExample

Clean Architecture GitHub Search Example

## Features
- Using ReactorKit
- Clean Architecture and DI with Swinject

## Architecture
- Uni-directional hierarchy
- ViewController -> Reactor -> UseCases -> Services

### Container
- Handle dependency injection using Swinject
```swift
...
container.autoregister(Network.self, initializer: DefaultNetwork.init)
container.autoregister(WebApi.self, initializer: DefaultWebApi.init)
...
```
- Usage
```swift
DefaultContainer.shared.resolve(Reactor.self)
```

### Resource
- Declaration
```swift
enum Resource<T> {
    case Loading
    case Success(T)
    case Failure
}
```
- Usage
```swift
return gitHubSearchUseCase.search(query: query, page: page)
    .flatMap { [weak self] resource -> Observable<Mutation> in
        switch resource {
        case let .Success(data):
        ...
        case .Loading:
        ...
        case .Failure:
        ...
        }
    }
```

### Services
- Service layer can contain web api, worker, cache ...
```swift
protocol WebApi {
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>>
    ...
}
```

### UseCases
- UseCases handle usecases of entity(model) using service layer
```swift
final class DefaultGitHubSearchUseCase: GitHubSearchUseCase {
    let webApi: WebApi
    ...
    func search(query: String, page: Int) -> Observable<Resource<GitHubSearch>> {
        return webApi.search(query: query, page: page)
    }
}
```

### View and Reactor
- Each viewControllers implements StoryboardView from reactorKit and has reactor
- View gets resources from reactor and handles logics about controlling view
- Reactor (kind of ViewModel) handles resources using useCases









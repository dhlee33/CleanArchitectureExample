# CleanArchitectureExample

Clean Architecture GitHub Search Example

## Features
- Using ReactorKit
- Clean Architecture and DI with Swinject
- Navigation with RxFlow

## Architecture
- Uni-directional hierarchy
- ViewController -> Reactor -> UseCases -> Managers

### Container
- Handle dependency injection using Swinject
```swift
...
container.autoregister(RequestManager.self, initializer: DefaultRequestManager.init)
container.autoregister(GitHubSearchUseCase.self, initializer: DefaultGitHubSearchUseCase.init)
...
```
- Usage
```swift
container.resolve(GitHubSearchUseCase.self)
```

### Managers
- Managers are responsible for specific services.
```swift
protocol ToastManager {
    func showToast(_ type: ToastType)
    ...
}
```

### UseCases
- UseCases handle usecases of entity using manager layer
```swift
final class DefaultGitHubSearchUseCase: GitHubSearchUseCase {
    private let requestManager: RequestManager
    ...
    func search(query: String, page: Int) -> Single<GitHubSearch> {
        return requestManager.get(...)
    }
}
```

### View and Reactor
- Each viewControllers implements View from reactorKit and has reactor
- View gets resources from reactor and handles logics about controlling view
- Reactor (kind of ViewModel) handles resources using useCases









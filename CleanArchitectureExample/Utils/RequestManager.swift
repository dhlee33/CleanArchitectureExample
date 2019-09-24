//
//  RequestManager.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift
import Alamofire

enum Resource<T> {
    case Loading
    case Success(T)
    case Failure
}

protocol Network {
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Observable<Resource<T>>
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Observable<Resource<T>>
}

extension Network { // implement func with default value
    func get<T: Codable>(_ path: String, responseType: T.Type) -> Observable<Resource<T>> {
        return get(path, parameters: nil, responseType: T.self)
    }
    func post<T: Codable>(_ path: String, responseType: T.Type) -> Observable<Resource<T>> {
        return post(path, parameters: nil, responseType: T.self)
    }
}

final class DefaultNetwork: Network {
    // TODO: Replace RequestManager singleton with RxAlamofire
    private func request<T: Codable>(_ path: String, method: HTTPMethod, parameters: Parameters?, responseType: T.Type) -> Observable<Resource<T>> {
        return Observable.create { observer in
            observer.onNext(Resource.Loading)
            guard let url = URL(string: path) else {
                observer.onNext(Resource.Failure)
                observer.onCompleted()
                return Disposables.create()
            }
            let request = Alamofire.request(url, method: method)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess, let data = response.data else {
                        observer.onNext(Resource.Failure)
                        observer.onCompleted()
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode(T.self, from: data)
                        observer.onNext(Resource.Success(value))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(Resource.Failure)
                        observer.onCompleted()
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
        .observeOn(MainScheduler.asyncInstance)
    }
    
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Observable<Resource<T>> {
        return request(path, method: .get, parameters: parameters, responseType: T.self)
    }
    
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Observable<Resource<T>> {
        return request(path, method: .post, parameters: parameters, responseType: T.self)
    }
}


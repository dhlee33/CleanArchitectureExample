//
//  RequestManager.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift
import Alamofire

enum NetworkError: Error, LocalizedError {
    case invalidPath
    case networkError
    case typeError
}

protocol Network {
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
}

extension Network { // implement func with default value
    func get<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return get(path, parameters: nil, responseType: T.self)
    }
    func post<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return post(path, parameters: nil, responseType: T.self)
    }
}

final class DefaultNetwork: Network {
    private func request<T: Codable>(_ path: String, method: HTTPMethod, parameters: Parameters?, responseType: T.Type) -> Single<T> {
        return Single.create { single in
            guard let url = URL(string: path) else {
                single(.error(NetworkError.invalidPath))
                return Disposables.create()
            }
            let request = Alamofire.request(url, method: method, parameters: parameters)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess, let data = response.data else {
                        single(.error(NetworkError.networkError))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode(T.self, from: data)
                        single(.success(value))
                    } catch {
                        single(.error(NetworkError.typeError))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
        .observeOn(MainScheduler.asyncInstance)
    }
    
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .get, parameters: parameters, responseType: T.self)
    }
    
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .post, parameters: parameters, responseType: T.self)
    }
}


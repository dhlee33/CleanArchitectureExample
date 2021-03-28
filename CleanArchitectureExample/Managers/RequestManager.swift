//
//  RequestManager.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import RxSwift
import Alamofire

enum RequestManagerError: Error, LocalizedError {
    case invalidPath
    case failed
    case typeError
}

protocol RequestManager {
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
}

extension RequestManager {
    func get<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return get(path, parameters: nil, responseType: T.self)
    }
    func post<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return post(path, parameters: nil, responseType: T.self)
    }
}

final class DefaultRequestManager: RequestManager {
    private func request<T: Codable>(_ path: String, method: HTTPMethod, parameters: Parameters?, responseType: T.Type) -> Single<T> {
        return Single.create { single in
            guard let url = URL(string: path) else {
                single(.error(RequestManagerError.invalidPath))
                return Disposables.create()
            }
            let request = Alamofire.request(url, method: method, parameters: parameters)
                .validate()
                .responseJSON { response in
                    guard response.result.isSuccess, let data = response.data else {
                        single(.error(RequestManagerError.failed))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode(T.self, from: data)
                        single(.success(value))
                    } catch {
                        single(.error(RequestManagerError.typeError))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .get, parameters: parameters, responseType: T.self)
    }
    
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .post, parameters: parameters, responseType: T.self)
    }
}


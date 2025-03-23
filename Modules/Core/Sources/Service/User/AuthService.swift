//
//  SignupService.swift
//  Newdok
//
//  Created by 권민재 on 3/18/25.
//

import Foundation
import Moya
import Combine

protocol AuthServiceProtocol {
    func login(loginId: String, password: String) -> AnyPublisher<Bool, Error>
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) -> AnyPublisher<Bool, Error>
    func authSMS(phoneNumber: String) -> AnyPublisher<Bool, Error>
}

class AuthService: AuthServiceProtocol {
    
    private let provider: MoyaProvider<UserAPI>
    
    init(provider: MoyaProvider<UserAPI> = MoyaProvider<UserAPI>()) {
        self.provider = provider
    }
    
    func login(loginId: String, password: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.provider.request(.login(loginId: loginId, password: password)) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        promise(.success(true))
                    } else {
                        promise(.failure(URLError(.badServerResponse)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.provider.request(.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender)) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        promise(.success(true))
                    } else {
                        promise(.failure(URLError(.badServerResponse)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func authSMS(phoneNumber: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.provider.request(.authSMS(phoneNumber: phoneNumber)) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        promise(.success(true))
                    } else {
                        promise(.failure(URLError(.badServerResponse)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

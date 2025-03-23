//
//  UserVerificationService.swift
//  Newdok
//
//  Created by 권민재 on 3/18/25.
//
import Moya
import Combine
import Foundation

protocol UserVerificationServiceProtocol {
    func checkPhoneNumber(phoneNumber: String) -> AnyPublisher<Bool, Error>
    func checkIDDup(loginId: String) -> AnyPublisher<Bool, Error>
}

class UserVerificationService: UserVerificationServiceProtocol {
    
    private let provider: MoyaProvider<UserAPI>
    
    init(provider: MoyaProvider<UserAPI> = MoyaProvider<UserAPI>()) {
        self.provider = provider
    }
    
    func checkPhoneNumber(phoneNumber: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.provider.request(.checkPhoneNumber(phoneNumber: phoneNumber)) { result in
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
    
    func checkIDDup(loginId: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.provider.request(.checkIDDup(loginId: loginId)) { result in
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

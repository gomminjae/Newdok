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
    
    
    func login(loginId: String, password: String) -> AnyPublisher<Bool, any Error> {
        return provider.requestPublisher(.login(loginId: loginId, password: password))
            .tryMap { response in
                guard(200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) -> AnyPublisher<Bool, Error> {
        return provider.requestPublisher(.signup(loginId: loginId, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender))
            .tryMap { response in
                guard (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func authSMS(phoneNumber: String) -> AnyPublisher<Bool, any Error> {
        return provider.requestPublisher(.authSMS(phoneNumber: phoneNumber))
            .tryMap { response in
                guard (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

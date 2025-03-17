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
    func checkPhoneNumber(phoneNumber: String) -> AnyPublisher<Bool,Error>
    func checkIDDup(loginId: String) -> AnyPublisher<Bool, Error>
    
}



class UserVerificationService: UserVerificationServiceProtocol {
    
    private let provider: MoyaProvider<UserAPI>
    
    init(provider: MoyaProvider<UserAPI> = MoyaProvider<UserAPI>()) {
        self.provider = provider
    }
    
    
    func checkPhoneNumber(phoneNumber: String) -> AnyPublisher<Bool, any Error> {
        
        return provider.requestPublisher(.checkPhoneNumber(phoneNumber: phoneNumber))
            .tryMap { response in
                guard(200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    func checkIDDup(loginId: String) -> AnyPublisher<Bool, any Error> {
        return provider.requestPublisher(.checkIDDup(loginId: loginId))
            .tryMap { response in
                guard(200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
}

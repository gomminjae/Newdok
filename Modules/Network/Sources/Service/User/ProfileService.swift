//
//  ProfileService.swift
//  Newdok
//
//  Created by 권민재 on 3/18/25.
//

import Moya
import Combine
import Foundation

protocol ProfileServiceProtocol {
    func updateNickname(nickname: String) -> AnyPublisher<Void, Error>
    func updatePassword(loginId: String, prevPassword: String, password: String) -> AnyPublisher<Void, Error>
    func updateInterest(interestsId: [Int]) -> AnyPublisher<Void, Error>
    func updateIndustry(industryId: Int) -> AnyPublisher<Void, Error>
    func updatePhoneNumber(phoneNumber: String) -> AnyPublisher<Void, Error>
    
    func preInvestigate(industryId: Int, interestIds: [Int]) -> AnyPublisher<Void, Error>
}


class ProfileService {

    private let provider: MoyaProvider<UserAPI>
    
    init(provider: MoyaProvider<UserAPI> = MoyaProvider<UserAPI>()) {
        self.provider = provider
    }
    
}

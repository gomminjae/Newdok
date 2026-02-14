//
//  SignupUseCase.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

public struct SignupRequest {
    public let loginId: String
    public let password: String
    public let phoneNumber: String
    public let nickname: String
    public let birthYear: String
    public let gender: String

    public init(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) {
        self.loginId = loginId
        self.password = password
        self.phoneNumber = phoneNumber
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
    }
}

public protocol SignupUseCase {
    func execute(request: SignupRequest) async throws -> User
}

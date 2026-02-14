//
//  LoginUseCase.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

public enum LoginError: Error {
    case invalidCredentials
    case accountNotFound
    case networkError(Error)
}

public protocol LoginUseCase {
    func execute(loginId: String, password: String) async throws -> User
}

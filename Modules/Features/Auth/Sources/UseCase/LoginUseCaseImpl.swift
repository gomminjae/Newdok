//
//  LoginUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import AuthDomain
import Shared

public final class LoginUseCaseImpl: LoginUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(provider: SocialProvider, idToken: String) async throws -> AuthUser {
        let (user, _) = try await authRepository.login(provider: provider, idToken: idToken)
        return user
    }
}

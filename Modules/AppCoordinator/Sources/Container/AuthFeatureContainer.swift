//
//  AuthFeatureContainer.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import Foundation
import Swinject
import Domain
import Signup
import Auth

public final class AuthFeatureContainer {
    private let container: Container

    public init(parent: Container = AppDIContainer.shared.container) {
        container = Container(parent: parent)
    }

    @MainActor public func makeSignupViewModel() -> SignupViewModel {
        return container.resolve(SignupViewModel.self)!
    }

    @MainActor public func makeLoginViewModel() -> LoginViewModel {
        return container.resolve(LoginViewModel.self)!
    }
}

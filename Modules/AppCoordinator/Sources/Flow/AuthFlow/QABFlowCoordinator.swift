//
//  AuthFlowCoordinator.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import SwiftUI
import Shared
import Auth
import Signup
import Launch

@MainActor
final class QABFlowCoordinator: ObservableObject {
    let container: AuthFeatureContainer

    init(container: AuthFeatureContainer = AuthFeatureContainer()) {
        self.container = container
    }

    lazy var loginViewModel: LoginViewModel = {
        LoginViewModel(userUserCase: container.useCase)
    }()
}

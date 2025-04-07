//
//  LoginViewModel.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import Combine
import Domain

@MainActor
public protocol LoginViewModelBindable: ObservableObject {
    
    var loginId: String { get set }
    var password: String  { get set }
    
    var isUserIdValid: Bool { get set }
    var isUserPwdValid: Bool { get set }
    
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    
    func login()
}



@MainActor
public final class LoginViewModel: LoginViewModelBindable {
    
    private let userUseCase: UserUseCase
    
    @Published public var loginId: String
    
    @Published public var password: String
    
    @Published public var isUserIdValid: Bool
    
    @Published public var isUserPwdValid: Bool
    
    @Published public var errorMessage: String?
    
    @Published public var isLoading: Bool
    
    @Published public var isSecurePassword: Bool = true
    
    @Published public var user: User?
    
    
    
    public init(userUserCase: UserUseCase) {
        self.userUseCase = userUserCase
        self.loginId = ""
        self.password = ""
        self.isUserIdValid = false
        self.isUserPwdValid = false
        self.isLoading = false
        self.errorMessage = nil
       
    }
    
    
    public func login() {
        Task {
            do {
                user = try await userUseCase.login(loginId: loginId, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    public var isLoginEnabled: Bool {
        !loginId.isEmpty && !password.isEmpty
    }

    
    
    
    
    
}

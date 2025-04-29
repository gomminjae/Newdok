//
//  LoginViewModel.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import Combine
import Domain
import Core
import Shared

@MainActor
public protocol LoginViewModelBindable: ObservableObject {
    
    var loginId: String { get set }
    var password: String  { get set }
    
    var isUserIdValid: Bool { get set }
    var isUserPwdValid: Bool { get set }
    
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    
    func login(onSuccess: @escaping () -> Void)
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
    
    @Published public var isLoginIdError: Bool = false
    @Published public var isPasswordError: Bool = false

    
    
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("nickname") public var nickname: String = ""
    @AppStorage("email") public var email: String = ""
    
    
    
    public init(userUserCase: UserUseCase) {
        self.userUseCase = userUserCase
        self.loginId = ""
        self.password = ""
        self.isUserIdValid = false
        self.isUserPwdValid = false
        self.isLoading = false
        self.errorMessage = nil
       
    }
    
    
    public func login(onSuccess: @escaping () -> Void) {
        Task {
            
            do {
                let (user,token) = try await userUseCase.login(loginId: loginId, password: password)
                //self.user = user
                print("유저유저\(user)")
                TokenStorage.accessToken = token
                errorMessage = nil
                isLoginIdError = false
                isPasswordError = false
                isLoggedIn = true
                isGuest = false
                nickname = user.nickname
                email = user.subscribeEmail
                
                await MainActor.run {
                    onSuccess()
                }
                
                
            } catch let error as NetworkError {
                switch error {
                case .serverError(let statusCode, let message):
                    if statusCode == 400 {
                        let newMessage = message ?? ""
                        if newMessage.contains("비밀번호") {
                            errorMessage = "비밀번호가 일치하지 않습니다"
                            isPasswordError = true
                            isLoginIdError = false
                        } else if newMessage.contains("계정") {
                            errorMessage = "등록되지 않은 계정이거나, 아이디를 다시 확인해주세요"
                            isLoginIdError = true
                            isPasswordError = false
                        }
                    }
                default:
                    isPasswordError = false
                    isLoginIdError = false
                }
                
            }
        }
    }
    
    public var isLoginEnabled: Bool {
        !loginId.isEmpty && !password.isEmpty
    }

    
    
    
    
    
}

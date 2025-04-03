//
//  SignupViewModel.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//

import Foundation
import Domain

@MainActor
public protocol SignupViewModelBindable: ObservableObject {
    
    var loginId: String { get set }
    var password: String { get set }
    var phoneNumber: String { get set }
    var nickname: String { get set }
    var birthYear: String { get set }
    var gender: String { get set }
    
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func signup() async
    func checkPhoneNumber() async
    func checkIDDup() async
    func authSMS() async
    
}


@MainActor
class SignupViewModel:  SignupViewModelBindable {
    
    private let userUseCase: UserUseCase
    
    @Published public var loginId: String
    @Published public var password: String
    @Published public var phoneNumber: String
    @Published public var nickname: String
    @Published public var birthYear: String
    @Published public var gender: String
    
    @Published public var isLoading: Bool
    @Published public var errorMessage: String?
    
    
    public init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        self.loginId = ""
        self.password = ""
        self.phoneNumber = ""
        self.nickname = ""
        self.birthYear = ""
        self.gender = ""
        self.isLoading = false
        self.errorMessage = nil
        
        
    }
    func signup() async {
        do {
            let response = try await userUseCase.signup(
                loginId: loginId,
                password: password,
                phoneNumber: phoneNumber,
                nickname: nickname,
                birthYear: birthYear,
                gender: gender
            )
            print("회원가입 성공")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkPhoneNumber() async {
        do {
            let response = try await userUseCase.checkPhoneNumber(phoneNumber)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkIDDup() async {
        do {
            let response = try await userUseCase.checkIDDup(loginId)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func authSMS() async {
        do {
            try await userUseCase.authSMS(phoneNumber: phoneNumber)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
 

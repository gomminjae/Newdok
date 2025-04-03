//
//  LoginViewModel.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import Combine
import Domain
import Network

class LoginViewModel: ObservableObject {
    
    @Published var loginId: String = ""
    @Published var password: String = ""
    
    @Published var user: User?
    
    @Published var errorMessage: String?
    
    
    
    
    
    private let userUseCase: UserUseCase
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }
    
    
    @MainActor
    func login() async {
        do {
            let response = try await userUseCase.login(loginId: loginId, password: password)
            self.user = response
        } catch {
            if let errorResponse = error as? ErrorResponse {
                errorMessage = errorResponse.message
            } else {
                errorMessage = "알 수 없는 오류가 발생했습니다."
            }
        }
    }
    
    
}

//
//  LoginViewModel.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var userId: String = ""
    @Published var userPwd: String = ""
    
    @Published var isUserIdValid: Bool = false
    @Published var isUserPwdValid: Bool = false
    
    @Published var errorMessage: String? = nil
    
    private var cancellable = Set<AnyCancellable>()
    
    
    
    
}

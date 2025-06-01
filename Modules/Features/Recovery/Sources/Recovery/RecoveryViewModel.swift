//
//  RecoveryViewModel.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Domain


@MainActor
public class RecoveryViewModel: ObservableObject {
    
    private let userUseCase: UserUseCase
    
    @Published var currentPage: Int = 0
    
    @Published public var users: [SimpleUser] = []
    
    @Published public var phoneNumber: String = ""
    
    
    @Published public var password: String = ""
    @Published public var checkPassword: String = ""
    
    @Published public var loginID: String = ""
    
    
    public init(useCase: UserUseCase) {
        self.userUseCase = useCase
    }
    
    
    
    func findMyIds() async {
        do {
            let response = try await userUseCase.checkPhoneNumber(phoneNumber)
            users = response
        } catch {
            print("핸드폰 번호 조회 에러")
        }
    }
    
    
    
}

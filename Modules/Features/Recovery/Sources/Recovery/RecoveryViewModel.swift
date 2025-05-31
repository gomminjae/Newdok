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
    
    @Published public var phoneNumber: String = ""
    
    
    @Published public var password: String = ""
    @Published public var checkPassword: String = ""
    
    
    public init(useCase: UserUseCase) {
        self.userUseCase = useCase
    }
    
    
    
    func findMyIds() async {
        do {
            let response = try await userUseCase.checkPhoneNumber(phoneNumber)
        } catch {
            print("핸드폰 번호 조회 에러")
        }
    }
    
}

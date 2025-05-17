//
//  MypageViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Combine
import Domain

protocol MypageViewModelBindable {
    
}

@MainActor
public class MypageViewModel: ObservableObject {
    
    @Published var nickname: String = ""
    @Published var user: User?
    
    @Published var shownicknameToast: Bool = false
    @Published var showIndustryToast: Bool = false
    @Published var showInterestToast: Bool = false
    
    
    private let useCase: UserUseCase
    
    public init(useCase: UserUseCase) {
        self.useCase = useCase
    }
    
    public func fetchuserInfo() async {
        do {
            let response = try await useCase.getProfile()
            user = response
        } catch {
            print("프로필 조회 실패")
        }
    }
    
    
    
    public func updateNickname(nickname: String) async {
        do {
            try await useCase.updateNickname(nickname)
        } catch {
            print("닉네임 변경 실패")
        }
    }
    

    
    public func updateIndustry(id: Int) async {
        do {
            try await useCase.updateIndustry(id)
        } catch {
            print("산업 변경 실패")
        }
    }
    
    public func updateInterests(ids: [Int]) async {
        do {
            try await useCase.updateInterest(ids)
        } catch {
            print("관심사 변경 실패")
        }
    }
    
    
    
    
    
}

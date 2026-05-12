//
//  WithdrawViewModel.swift
//  Withdraw
//
//  Created by 권민재 on 7/18/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import Observation

@Observable
@MainActor
public final class WithdrawViewModel: ErrorHandling {
    public var nickName: String = ""
    public var newsletterCount: Int = 0
    public var articleCount: Int = 0
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var withdrawSuccess: Bool = false
    public var currentError: AppError?

    private let userUseCase: MypageUserUseCase
    private let statsUseCase: MypageStatsUseCase
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        userUseCase: MypageUserUseCase,
        statsUseCase: MypageStatsUseCase,
        tokenStorage: TokenStorageProtocol = TokenStorageWrapper.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.userUseCase = userUseCase
        self.statsUseCase = statsUseCase
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
    }

    public func fetchUserInfo() async {
        await performAsync(feature: "withdraw", operation: "fetchUserInfo", loadingBinding: \.isLoading) {
            let user = try await userUseCase.getProfile()
            self.nickName = user.nickname

            self.newsletterCount = try await statsUseCase.fetchSubscriptionCount()
            self.articleCount = try await statsUseCase.fetchReceivedArticleCount()
        }
    }

    public func withdraw() async {
        await performAsync(feature: "withdraw", operation: "withdraw", loadingBinding: \.isLoading) {
            try await userUseCase.withdraw()

            // 탈퇴 성공 시 모든 로컬 데이터 정리
            clearAllLocalData()

            // 캐시된 뷰모델 초기화
            NotificationCenter.default.post(name: .init("ResetMypageCache"), object: nil)

            self.withdrawSuccess = true
        }
    }

    private func clearAllLocalData() {
        // 액세스 토큰 삭제
        tokenStorage.clear()

        // UserInfo 삭제
        userInfoStore.clear()

        // UserDefaults의 모든 사용자 관련 데이터 삭제
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "isLoggedIn")
        userDefaults.removeObject(forKey: "isGuest")
        userDefaults.removeObject(forKey: "nickname")
        userDefaults.removeObject(forKey: "email")

        // 기타 앱 관련 데이터도 정리
        userDefaults.removeObject(forKey: "accessToken")
        userDefaults.removeObject(forKey: "local_user_info")
    }
}

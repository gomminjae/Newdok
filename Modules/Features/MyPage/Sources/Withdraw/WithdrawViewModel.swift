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
    public var isWithdrawing: Bool = false
    public var errorMessage: String?
    public var withdrawSuccess: Bool = false
    public var currentError: AppError?

    private let fetchProfileUseCase: FetchMypageProfileUseCase
    private let fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCase
    private let fetchArticleCountUseCase: FetchReceivedArticleCountUseCase
    private let withdrawUseCase: MypageWithdrawUseCase
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let onCleanup: @MainActor () -> Void

    public init(
        fetchProfileUseCase: FetchMypageProfileUseCase,
        fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCase,
        fetchArticleCountUseCase: FetchReceivedArticleCountUseCase,
        withdrawUseCase: MypageWithdrawUseCase,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        onCleanup: @escaping @MainActor () -> Void = {}
    ) {
        self.fetchProfileUseCase = fetchProfileUseCase
        self.fetchSubscriptionCountUseCase = fetchSubscriptionCountUseCase
        self.fetchArticleCountUseCase = fetchArticleCountUseCase
        self.withdrawUseCase = withdrawUseCase
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.onCleanup = onCleanup
    }

    public func fetchUserInfo() async {
        await performAsync(feature: "withdraw", operation: "fetchUserInfo", loadingBinding: \.isLoading) {
            let user = try await fetchProfileUseCase.execute()
            self.nickName = user.nickname

            self.newsletterCount = try await fetchSubscriptionCountUseCase.execute()
            self.articleCount = try await fetchArticleCountUseCase.execute()
        }
    }

    public func withdraw() async {
        guard !isWithdrawing else { return }
        isWithdrawing = true
        defer { isWithdrawing = false }

        await performAsync(feature: "withdraw", operation: "withdraw", loadingBinding: \.isLoading) {
            try await withdrawUseCase.execute()

            clearAllLocalData()
            onCleanup()

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

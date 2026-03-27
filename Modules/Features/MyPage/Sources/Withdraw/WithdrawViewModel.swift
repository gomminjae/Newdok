//
//  WithdrawViewModel.swift
//  Withdraw
//
//  Created by 권민재 on 7/18/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Domain
import Shared

@MainActor
public final class WithdrawViewModel: ObservableObject, ErrorHandling {
    @Published public var nickName: String = ""
    @Published public var newsletterCount: Int = 0
    @Published public var articleCount: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var withdrawSuccess: Bool = false
    @Published public var currentError: AppError?

    private let userUseCase: UserUseCase
    private let newsletterUseCase: NewsletterUseCase
    private let articleUseCase: ArticleUseCase

    public init(
        userUseCase: UserUseCase,
        newsletterUseCase: NewsletterUseCase,
        articleUseCase: ArticleUseCase
    ) {
        self.userUseCase = userUseCase
        self.newsletterUseCase = newsletterUseCase
        self.articleUseCase = articleUseCase
    }

    public func fetchUserInfo() async {
        await performAsync(feature: "withdraw", operation: "fetchUserInfo", loadingBinding: \.isLoading) {
            let user = try await userUseCase.getProfile()
            self.nickName = user.nickname

            self.newsletterCount = try await newsletterUseCase.fetchSubscriptionCount()
            self.articleCount = try await articleUseCase.fetchReceivedArticleCount()
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
        TokenStorage.clear()

        // UserInfo 삭제
        UserInfoStore.shared.clear()

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

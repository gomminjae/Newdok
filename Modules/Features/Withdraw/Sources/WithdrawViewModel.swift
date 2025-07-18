//
//  WithdrawViewModel.swift
//  Withdraw
//
//  Created by 권민재 on 7/18/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import Foundation
import Domain

@MainActor
public final class WithdrawViewModel: ObservableObject {
    @Published public var nickName: String = ""
    @Published public var newsletterCount: Int = 0
    @Published public var articleCount: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var withdrawSuccess: Bool = false

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
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await userUseCase.getProfile()
            self.nickName = user.nickname

            self.newsletterCount = try await newsletterUseCase.fetchSubscriptionCount()
            self.articleCount = try await articleUseCase.fetchReceivedArticleCount()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func withdraw() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await userUseCase.withdraw()
            self.withdrawSuccess = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 

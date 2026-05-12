//
//  TokenStorageWrapper.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public final class TokenStorageWrapper: TokenStorageProtocol, @unchecked Sendable {
    public static let shared = TokenStorageWrapper()

    private init() {}

    public var accessToken: String? {
        get { TokenStorage.accessToken }
        set { TokenStorage.accessToken = newValue }
    }

    public var hasCompletedOnboarding: Bool {
        get { TokenStorage.hasCompletedOnboarding }
        set { TokenStorage.hasCompletedOnboarding = newValue }
    }

    public var hasValidToken: Bool {
        TokenStorage.hasValidToken
    }

    public var shouldShowSubscribeStatePopup: Bool {
        TokenStorage.shouldShowSubscribeStatePopup
    }

    public func clear() {
        TokenStorage.clear()
    }

    public func markOnboardingCompleted() {
        TokenStorage.markOnboardingCompleted()
    }

    public func hideSubscribeStatePopupForToday() {
        TokenStorage.hideSubscribeStatePopupForToday()
    }

    public func migrateTokenIfNeeded() {
        TokenStorage.migrateTokenIfNeeded()
    }
}

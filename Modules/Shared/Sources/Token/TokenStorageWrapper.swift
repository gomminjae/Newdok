//
//  TokenStorageWrapper.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public final class TokenStorageWrapper: TokenStorageProtocol, Sendable {
    public static let shared = TokenStorageWrapper()

    private init() {}

    public var accessToken: String? {
        TokenStorage.accessToken
    }

    public var hasCompletedOnboarding: Bool {
        TokenStorage.hasCompletedOnboarding
    }

    public var hasValidToken: Bool {
        TokenStorage.hasValidToken
    }

    public var shouldShowSubscribeStatePopup: Bool {
        TokenStorage.shouldShowSubscribeStatePopup
    }

    public func saveAccessToken(_ token: String?) {
        TokenStorage.accessToken = token
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

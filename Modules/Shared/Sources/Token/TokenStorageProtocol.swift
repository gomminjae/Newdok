//
//  TokenStorageProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public protocol TokenStorageProtocol: Sendable {
    var accessToken: String? { get }
    var hasCompletedOnboarding: Bool { get }
    var hasValidToken: Bool { get }
    var shouldShowSubscribeStatePopup: Bool { get }

    func saveAccessToken(_ token: String?)
    func clear()
    func markOnboardingCompleted()
    func hideSubscribeStatePopupForToday()
    func migrateTokenIfNeeded()
}

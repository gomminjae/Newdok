//
//  TokenStorageProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public protocol TokenStorageProtocol {
    var accessToken: String? { get set }
    var hasCompletedOnboarding: Bool { get set }
    var hasValidToken: Bool { get }
    var shouldShowSubscribeStatePopup: Bool { get }

    func clear()
    func markOnboardingCompleted()
    func hideSubscribeStatePopupForToday()
    func migrateTokenIfNeeded()
}

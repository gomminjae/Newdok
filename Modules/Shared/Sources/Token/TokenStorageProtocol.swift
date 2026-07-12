//
//  TokenStorageProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public protocol TokenStorageProtocol: Sendable {
    var accessToken: String? { get }
    var hasValidToken: Bool { get }

    @discardableResult
    func saveAccessToken(_ token: String?) -> Bool
    func clear()
    func migrateTokenIfNeeded()
}

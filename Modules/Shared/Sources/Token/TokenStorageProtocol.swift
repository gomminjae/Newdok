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

    func saveAccessToken(_ token: String?)
    func clear()
    func migrateTokenIfNeeded()
}

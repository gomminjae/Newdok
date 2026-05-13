//
//  UserInfoStoreProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public protocol UserInfoStoreProtocol: Sendable {
    func save(_ user: UserInfo)
    func load() -> UserInfo?
    func clear()
    var hasProfile: Bool { get }
}

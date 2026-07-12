//
//  AppState.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation
import Observation

public enum AuthState: Equatable {
    case guest
    case authenticated
}

@Observable
@MainActor
public final class AppState {
    public var authState: AuthState = .guest
    
    public static let shared = AppState()
    
    private init() {}
    
    // 로그아웃 시 호출
    public func logout() {
        authState = .guest
    }
    
    // 로그인 시 호출
    public func login() {
        authState = .authenticated
    }
}

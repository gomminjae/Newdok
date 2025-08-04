//
//  AppState.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation
import Combine


public enum AuthState {
    case guest
    case authenticated
}


public final class AppState: ObservableObject {
    
    @Published public var authState: AuthState = .guest
    
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

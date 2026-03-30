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

@MainActor
public final class AppState: ObservableObject, Authenticatable {
    @Published public var authState: AuthState = .guest

    public static let shared = AppState()

    public var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }

    private init() {}

    public func logout() {
        authState = .guest
    }

    public func login() {
        authState = .authenticated
    }
}

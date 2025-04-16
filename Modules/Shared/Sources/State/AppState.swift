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
    
}

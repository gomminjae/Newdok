//
//  QABRouter.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import SwiftUI
import Shared

public final class QABRouter: ObservableObject, OnboardingRouting {
    @Published public var path: NavigationPath = NavigationPath()
    
    public func push(_ route: Shared.OnboardingRoute) {
        path.append(route)
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func reset() {
        path = NavigationPath()
    }
    
}

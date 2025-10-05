//
//  AppRouter.swift
//  Shared
//
//  Created by 권민재 on 4/9/25.
//
import SwiftUI


@MainActor
public final class AppRouter: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var root: AppRoute = .onboarding

    public init() {
        // Swipe back 알림 리스너 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSwipeBack),
            name: .init("SwipeBack"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func push(_ route: AppRoute) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func resetTo(_ route: AppRoute) {
        path = NavigationPath()
        root = route
    }

    public func reset() {
        path = NavigationPath()
    }
    
    @objc private func handleSwipeBack() {
        pop()
    }
}

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

    public init() {}

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
}

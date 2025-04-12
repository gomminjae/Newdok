//
//  AppRoute.swift
//  Shared
//
//  Created by 권민재 on 4/9/25.
//


public enum AppRoute: Hashable {
    case onboarding
    case login
    case signup
    case home
    case profile(userId: String)
    case tabbar
}

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
    case profile
    case explore(day: Int? = nil, selectedTab: Int? = nil)
    case tabbar
    
    case brandDetail(id: String)
    case articleDetail(id: String)
    
    
    case editProfile
    case recovery
    
    //profile
    case accountManage
    case updatePhoneNumber
    case updatePassword
    
    
    case search
    
    
    
   
}

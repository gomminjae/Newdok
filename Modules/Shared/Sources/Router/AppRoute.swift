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
    case tabbar(selectedTab: NewDokTab? = nil, exploreDay: Int? = nil, exploreSelectedTab: Int? = nil)
    
    case brandDetail(id: String)
    case articleDetail(id: String, isPastArticle: Bool = false)
    
    case editProfile
    case recovery
    
    // 프로필 편집
    case editNickname
    case editIndustry
    case editInterest
    
    // profile
    case accountManage
    case updatePhoneNumber
    case updatePassword
    
    case search
    
    case serviceFeedback
    
    case withdraw
    
    // 고객센터
    case faq
    case feedback
    case termsMenu
    case editAlert
}

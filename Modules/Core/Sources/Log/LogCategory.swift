//
//  LogCategory.swift
//  Core
//
//  Created by 권민재 on 10/13/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//


import Foundation

/// 로그 카테고리 - Newdok 프로젝트 구조 기반
public enum LogCategory: String {
    
    // MARK: - Network & API
    case network = "🌐 Network"
    case api = "📡 API"
    case moya = "🔌 Moya"
    
    // MARK: - Features (화면별)
    case home = "🏠 Home"
    case explore = "🧭 Explore"
    case search = "🔍 Search"
    case bookmark = "⭐️ Bookmark"
    case subscribe = "✉️ Subscribe"
    case mypage = "👤 MyPage"
    case detail = "📄 Detail"
    case auth = "🔐 Auth"
    case login = "🚪 Login"
    case signup = "📝 Signup"
    case launch = "🚀 Launch"
    case survey = "📋 Survey"
    case recovery = "🔄 Recovery"
    case withdraw = "🚫 Withdraw"
    
    // MARK: - Domain (비즈니스 로직)
    case article = "📰 Article"
    case newsletter = "📬 Newsletter"
    case brand = "🏷️ Brand"
    case user = "👥 User"
    case industry = "🏭 Industry"
    
    // MARK: - Data Layer
    case repository = "💾 Repository"
    case useCase = "⚙️ UseCase"
    case dto = "📦 DTO"
    case entity = "🎯 Entity"
    
    // MARK: - UI & Navigation
    case ui = "🎨 UI"
    case navigation = "➡️ Navigation"
    case router = "🗺️ Router"
    case tabbar = "📱 TabBar"
    case popup = "💬 Popup"
    case toast = "🔔 Toast"
    
    // MARK: - Storage & Cache
    case storage = "💿 Storage"
    case cache = "📦 Cache"
    case userDefaults = "🗂️ UserDefaults"
    case token = "🎫 Token"
    
    // MARK: - System
    case lifecycle = "♻️ Lifecycle"
    case di = "💉 DI"
    case coordinator = "🎬 Coordinator"
    case state = "📊 State"
    
    // MARK: - Performance & Error
    case performance = "⚡️ Performance"
    case error = "❌ Error"
    case warning = "⚠️ Warning"
    case critical = "🔥 Critical"
    
    // MARK: - Debug
    case debug = "🐛 Debug"
    case test = "🧪 Test"
    
    // MARK: - General
    case general = "📝 General"
    
    /// 카테고리 표시 텍스트
    public var displayText: String {
        return rawValue
    }
}
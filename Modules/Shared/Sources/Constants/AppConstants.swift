//
//  AppConstants.swift
//  Shared
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation

// MARK: - App Constants
public enum AppConstants {
    
    // MARK: - Validation Rules
    public enum Validation {
        public static let idLengthRange = 6...12
        public static let nicknameLengthRange = 1...12
        public static let minimumInterestSelection = 3
        public static let phoneVerificationTimeout: TimeInterval = 180 // 3분
        public static let resendTimeInterval: TimeInterval = 60 // 1분
    }
    
    // MARK: - UI Constants
    public enum UI {
        public static let defaultPadding: CGFloat = 24
        public static let smallPadding: CGFloat = 16
        public static let cornerRadius: CGFloat = 12
        public static let shadowRadius: CGFloat = 4
        public static let buttonHeight: CGFloat = 56
        public static let textFieldHeight: CGFloat = 48
        
        // Animation Durations
        public static let fastAnimation: TimeInterval = 0.2
        public static let normalAnimation: TimeInterval = 0.3
        public static let slowAnimation: TimeInterval = 0.5
        
        // Toast Display Duration
        public static let toastDuration: TimeInterval = 1.0
    }
    
    // MARK: - Network Constants
    public enum Network {
        public static let requestTimeout: TimeInterval = 30
        public static let maxRetryCount = 3
        public static let retryDelay: TimeInterval = 1.0
    }
    
    // MARK: - Color Hex Values
    public enum Colors {
        public static let primaryBlue = "#2866D3"
        public static let errorRed = "#E32727"
        public static let successGreen = "#28A745"
        public static let warningOrange = "#FFA500"
        public static let textGray = "#565656"
        public static let lightGray = "#999999"
        public static let backgroundColor = "#F8F9FA"
    }
    
    // MARK: - API Related
    public enum API {
        public static let authorizationHeaderKey = "Authorization"
        public static let bearerPrefix = "Bearer "
        public static let contentTypeKey = "Content-Type"
        public static let applicationJson = "application/json"
    }
    
    // MARK: - Feature Flags
    public enum FeatureFlags {
        public static let enableLogging = true
        public static let enableCrashReporting = false
        public static let enableAnalytics = false
    }
    
    // MARK: - App Information
    public enum AppInfo {
        public static let version = "1.0.0"
        public static let buildNumber = "1"
        public static let appName = "Newdok"
    }
}

// MARK: - Error Messages
public enum ErrorMessages {
    public static let networkError = "네트워크 연결을 확인해주세요."
    public static let unknownError = "알 수 없는 오류가 발생했습니다."
    public static let sessionExpired = "세션이 만료되었습니다. 다시 로그인해주세요."
    public static let invalidCredentials = "아이디 또는 비밀번호가 올바르지 않습니다."
    public static let serverError = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
}

// MARK: - Success Messages
public enum SuccessMessages {
    public static let loginSuccess = "로그인이 완료되었습니다."
    public static let signupSuccess = "회원가입이 완료되었습니다."
    public static let profileUpdateSuccess = "프로필이 업데이트되었습니다."
    public static let bookmarkAdded = "북마크에 추가되었습니다."
    public static let bookmarkRemoved = "북마크가 해제되었습니다."
} 
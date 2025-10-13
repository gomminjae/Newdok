//
//  LogLevel.swift
//  Core
//
//  Created by 권민재 on 10/13/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Foundation

public enum LogLevel: Int, Comparable {
    case verbose = 0  // 상세 로그 (개발용)
    case debug = 1    // 디버그 로그
    case info = 2     // 정보성 로그
    case warning = 3  // 경고
    case error = 4    // 에러
    case critical = 5 // 치명적 에러
    
    /// 로그 레벨 이모지
    var emoji: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🔥"
        }
    }
    
    /// 로그 레벨 텍스트
    var text: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

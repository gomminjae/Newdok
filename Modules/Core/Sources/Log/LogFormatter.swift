//
//  LogFormatter.swift
//  Core
//
//  Created by 권민재 on 10/15/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//


import Foundation

/// 로그 메시지 포맷터
public protocol LogFormatter {
    func format(
        level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int,
        timestamp: Date
    ) -> String
}

// MARK: - Default Formatter
public final class DefaultLogFormatter: LogFormatter {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    public init() {}
    
    public func format(
        level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int,
        timestamp: Date
    ) -> String {
        let time = dateFormatter.string(from: timestamp)
        let fileName = (file as NSString).lastPathComponent
        
        return "\(level.emoji) [\(time)] \(category.emoji) \(category.displayText) | \(fileName):\(line) \(function) → \(message)"
    }
}

// MARK: - Simple Formatter
public final class SimpleLogFormatter: LogFormatter {
    public init() {}
    
    public func format(
        level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int,
        timestamp: Date
    ) -> String {
        return "\(level.emoji) \(category.emoji) \(message)"
    }
}
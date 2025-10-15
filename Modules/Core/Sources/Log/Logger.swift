//
//  Logger.swift
//  Core
//
//  Created by 권민재 on 10/15/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//


import Foundation

/// 메인 로거
public final class Logger {
    
    // MARK: - Singleton
    public static let shared = Logger()
    
    // MARK: - Properties
    private var outputs: [LogOutput] = []
    private var formatter: LogFormatter = DefaultLogFormatter()
    private var minimumLevel: LogLevel = .debug
    private let queue = DispatchQueue(label: "com.newdok.logger", qos: .utility)
    
    // MARK: - Configuration
    private init() {
        #if DEBUG
        // 개발 환경: Xcode 콘솔만 (중복 방지)
        outputs = [
            ConsoleLogOutput()
        ]
        minimumLevel = .verbose
        #else
        // 프로덕션 환경: 시스템 로그 + 파일 저장
        outputs = [
            OSLogOutput(),
            FileLogOutput()
        ]
        minimumLevel = .info
        #endif
    }
    
    /// 출력 대상 설정
    public func setOutputs(_ outputs: [LogOutput]) {
        queue.async { [weak self] in
            self?.outputs = outputs
        }
    }
    
    /// 포맷터 설정
    public func setFormatter(_ formatter: LogFormatter) {
        queue.async { [weak self] in
            self?.formatter = formatter
        }
    }
    
    /// 최소 로그 레벨 설정
    public func setMinimumLevel(_ level: LogLevel) {
        queue.async { [weak self] in
            self?.minimumLevel = level
        }
    }
    
    // MARK: - Logging Methods
    
    /// Verbose 로그
    public func verbose(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .verbose, category: category, message: message, file: file, function: function, line: line)
    }
    
    /// Debug 로그
    public func debug(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, category: category, message: message, file: file, function: function, line: line)
    }
    
    /// Info 로그
    public func info(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, category: category, message: message, file: file, function: function, line: line)
    }
    
    /// Warning 로그
    public func warning(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, category: category, message: message, file: file, function: function, line: line)
    }
    
    /// Error 로그
    public func error(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, category: category, message: message, file: file, function: function, line: line)
    }
    
    /// Critical 로그
    public func critical(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .critical, category: category, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(
        level: LogLevel,
        category: LogCategory,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        // 최소 레벨 체크
        guard level >= minimumLevel else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = Date()
            let formattedMessage = self.formatter.format(
                level: level,
                category: category,
                message: message,
                file: file,
                function: function,
                line: line,
                timestamp: timestamp
            )
            
            // 모든 출력 대상에 로그 전달
            self.outputs.forEach { output in
                output.write(formattedMessage, level: level, category: category)
            }
        }
    }
}

// MARK: - Convenience Global Functions
public func logVerbose(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.verbose(message, category: category, file: file, function: function, line: line)
}

public func logDebug(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.debug(message, category: category, file: file, function: function, line: line)
}

public func logInfo(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.info(message, category: category, file: file, function: function, line: line)
}

public func logWarning(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.warning(message, category: category, file: file, function: function, line: line)
}

public func logError(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.error(message, category: category, file: file, function: function, line: line)
}

public func logCritical(
    _ message: String,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.critical(message, category: category, file: file, function: function, line: line)
}
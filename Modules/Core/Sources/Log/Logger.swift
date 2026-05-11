//
//  Logger.swift
//  Core
//
//  Created by 권민재 on 10/15/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Foundation

/// 메인 로거
public final class Logger: Sendable {
    // MARK: - Singleton
    public static let shared = Logger()

    // MARK: - Properties
    private let outputs: [any LogOutput]
    private let formatter: any LogFormatter
    private let minimumLevel: LogLevel

    // MARK: - Configuration
    private init() {
        #if DEBUG
        // 개발 환경: Xcode 콘솔만 (중복 방지)
        self.outputs = [ConsoleLogOutput()]
        self.formatter = DefaultLogFormatter()
        self.minimumLevel = .verbose
        #else
        // 프로덕션 환경: 시스템 로그 + 파일 저장
        self.outputs = [OSLogOutput(), FileLogOutput()]
        self.formatter = DefaultLogFormatter()
        self.minimumLevel = .info
        #endif
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
        guard level >= minimumLevel else { return }

        let formattedMessage = formatter.format(
            level: level,
            category: category,
            message: message,
            file: file,
            function: function,
            line: line,
            timestamp: Date()
        )

        for output in outputs {
            output.write(formattedMessage, level: level, category: category)
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

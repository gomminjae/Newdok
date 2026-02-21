//
//  LogOutput.swift
//  Core
//
//  Created on 2025
//

import Foundation
import OSLog

/// 로그 출력 프로토콜
public protocol LogOutput {
    func write(_ message: String, level: LogLevel, category: LogCategory)
}

// MARK: - Console Output
public final class ConsoleLogOutput: LogOutput {
    public init() {}
    
    public func write(_ message: String, level: LogLevel, category: LogCategory) {
        print(message)
    }
}

// MARK: - OSLog Output
public final class OSLogOutput: LogOutput {
    private let logger: os.Logger
    
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.newdok") {
        self.logger = os.Logger(subsystem: subsystem, category: "app")
    }
    
    public func write(_ message: String, level: LogLevel, category: LogCategory) {
        switch level {
        case .verbose, .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
    }
}

// MARK: - File Output
public final class FileLogOutput: LogOutput {
    private let fileURL: URL
    private let fileHandle: FileHandle?
    private let queue = DispatchQueue(label: "com.newdok.filelogger")
    
    public init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        
        // Logs 디렉토리 생성
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        // 날짜별 로그 파일
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        self.fileURL = logsDirectory.appendingPathComponent("log-\(dateString).txt")
        
        // 파일이 없으면 생성
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
        
        // FileHandle 열기
        self.fileHandle = try? FileHandle(forWritingTo: fileURL)
    }
    
    deinit {
        try? fileHandle?.close()
    }
    
    public func write(_ message: String, level: LogLevel, category: LogCategory) {
        queue.async { [weak self] in
            guard let self = self,
                  let fileHandle = self.fileHandle,
                  let data = (message + "\n").data(using: .utf8) else {
                return
            }
            
            if #available(iOS 13.4, *) {
                try? fileHandle.seekToEnd()
                try? fileHandle.write(contentsOf: data)
            } else {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
        }
    }
}

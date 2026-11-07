//
//  ErrorContext.swift
//  Shared
//
//  Created by 권민재 on 2/28/26.
//

import Foundation
import Synchronization

public struct ErrorContext: Sendable {
    public let underlyingError: Error
    public let feature: String
    public let operation: String
    public let metadata: [String: String]
    public let timestamp: Date
    public let file: String
    public let line: Int

    public init(
        underlyingError: Error,
        feature: String,
        operation: String,
        metadata: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) {
        self.underlyingError = underlyingError
        self.feature = feature
        self.operation = operation
        self.metadata = metadata
        self.timestamp = Date()
        self.file = file
        self.line = line
    }

    public var summary: String {
        let fileName = (file as NSString).lastPathComponent
        var parts = ["[\(feature)] \(operation) failed"]
        parts.append("error=\(underlyingError)")
        parts.append("at \(fileName):\(line)")
        if !metadata.isEmpty {
            let meta = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            parts.append("metadata={\(meta)}")
        }
        return parts.joined(separator: " | ")
    }
}

public protocol ErrorLogging: Sendable {
    func logError(_ context: ErrorContext)
}

public enum ErrorLoggerRegistry {
    private static let logger = Mutex<(any ErrorLogging)?>(nil)

    public static func register(_ logger: ErrorLogging) {
        self.logger.withLock { $0 = logger }
    }

    public static var shared: ErrorLogging? {
        logger.withLock { $0 }
    }
}

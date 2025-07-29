//
//  EntityID.swift
//  Shared
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation

// MARK: - Type-Safe ID Protocol
public protocol EntityID: Hashable, CustomStringConvertible, Codable {
    var value: String { get }
    init(_ value: String)
}

extension EntityID {
    public var description: String { value }
}

// MARK: - Specific ID Types
public struct UserID: EntityID {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

public struct ArticleID: EntityID {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

public struct NewsletterID: EntityID {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Convenience Extensions
extension UserID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension ArticleID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension NewsletterID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
} 
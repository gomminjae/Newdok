//
//  SelectableItem.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//

import Foundation

public struct SelectableItem: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

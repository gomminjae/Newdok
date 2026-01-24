//
//  Option.swift
//  Domain
//
//  Created by 권민재 on 1/24/26.
//

import Foundation

public struct Option {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct OptionList {
    public let industries: [Option]
    public let interests: [Option]
    public let days: [Option]

    public init(industries: [Option], interests: [Option], days: [Option]) {
        self.industries = industries
        self.interests = interests
        self.days = days
    }
}

//
//  Gender.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//
import Foundation

public enum Gender {
    case male
    case female
    case other

    public init?(rawValue: String) {
        switch rawValue {
        case "남자": self = .male
        case "여자": self = .female
        case "그외": self = .other
        default: return nil
        }
    }
}

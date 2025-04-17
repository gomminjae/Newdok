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

    public init?(rawValue: String) {
        switch rawValue {
        case "남성": self = .male
        case "여성": self = .female
        default: return nil
        }
    }
}

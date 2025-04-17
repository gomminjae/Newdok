//
//  Industry.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//
import Domain

public struct IndustryDTO: Decodable {
    public let id: Int
    public let name: String
    
    public func toDomain() -> Industry {
        return Industry(id: id, name: name)
    }
}

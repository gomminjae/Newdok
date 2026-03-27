//
//  DetailInterestDTO.swift
//  DetailData
//

import DetailDomain

public struct DetailInterestDTO: Decodable {
    let id: Int
    let name: String

    public func toDomain() -> DetailInterest {
        return DetailInterest(id: id, name: name)
    }
}

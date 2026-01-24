//
//  OptionDTO.swift
//  Data
//
//  Created by 권민재 on 1/24/26.
//

import Domain

struct OptionDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> Domain.Option {
        return Domain.Option(id: id, name: name)
    }
}

struct OptionListDTO: Decodable {
    let industries: [OptionDTO]
    let interests: [OptionDTO]
    let days: [OptionDTO]

    func toDomain() -> Domain.OptionList {
        return Domain.OptionList(
            industries: industries.map { $0.toDomain() },
            interests: interests.map { $0.toDomain() },
            days: days.map { $0.toDomain() }
        )
    }
}

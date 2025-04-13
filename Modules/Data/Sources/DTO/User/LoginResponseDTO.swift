//
//  LoginResponseDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//

import Domain

struct LoginResponseDTO: Decodable {
    let user: UserDTO
    let accessToken: String
    
    
}

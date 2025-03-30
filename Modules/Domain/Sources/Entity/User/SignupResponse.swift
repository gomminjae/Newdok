//
//  SignupResponse.swift
//  Domain
//
//  Created by 권민재 on 3/30/25.
//

import Foundation


public struct SignupResponse {
    let user: SimpleUser
    let accessToken: String
    
    public init(user: SimpleUser, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}

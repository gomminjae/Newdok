//
//  SignupResponse.swift
//  Domain
//
//  Created by 권민재 on 3/30/25.
//

import Foundation


public struct SignupResponse {
    public let user: User
    public let accessToken: String
    
    public init(user: User, accessToken: String) {
        self.user = user
        self.accessToken = accessToken
    }
}

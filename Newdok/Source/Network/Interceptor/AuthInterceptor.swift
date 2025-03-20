//
//  AuthInterceptor.swift
//  Newdok
//
//  Created by 권민재 on 3/18/25.
//
import Moya
import Alamofire
import Foundation


final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    
    private init() {}
    
    
}

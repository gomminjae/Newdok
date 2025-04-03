//
//  NetworkError.swift
//  Network
//
//  Created by 권민재 on 3/28/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Foundation
import Moya
import Domain

public enum NetworkError: Error {
    case serverError(ErrorResponse)
    case decodeError(underlying: Error)
    case unknown
}

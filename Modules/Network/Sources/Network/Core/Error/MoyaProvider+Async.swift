//
//  NetworkErrorHandler.swift
//  Network
//
//  Created by 권민재 on 3/27/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Foundation
import Moya


public extension MoyaProvider {
    func asyncRequest<T: Decodable>(
        _ target: Target,
        decodeTo type: T.Type = T.self
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    if (200..<300).contains(response.statusCode) {
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: response.data)
                            continuation.resume(returning: decoded)
                        } catch {
                            continuation.resume(throwing: NetworkError.decodeError(underlying: error))
                        }
                    } else {
                        let error = ErrorMapper.map(response: response)
                        continuation.resume(throwing: error)
                    }

                case .failure(let moyaError):
                    let error = ErrorMapper.map(moyaError: moyaError)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

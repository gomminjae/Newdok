//
//  MypageProfileError.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import Shared

public enum MypageProfileError: Error {
    case userNotFound
}

extension MypageProfileError: AppErrorConvertible {
    public func toAppError() -> AppError {
        switch self {
        case .userNotFound:
            return .userMessage("사용자 정보를 찾을 수 없습니다")
        }
    }
}

//
//  MypageSMSResponseDTO.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain

public struct MypageSMSResponseDTO: Decodable, Sendable {
    let code: Int

    public func toDomain() -> MypageSMSResponse {
        return MypageSMSResponse(code: code)
    }
}

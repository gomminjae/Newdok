//
//  MypageSMSResponse.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public struct MypageSMSResponse {
    public let code: Int

    public init(code: Int) {
        self.code = code
    }
}

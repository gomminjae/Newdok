//
//  ErrorLogger.swift
//  Core
//
//  Created by 권민재 on 2/28/26.
//

import Foundation
import Shared

public struct CoreErrorLogger: ErrorLogging {
    public init() {}

    public func logError(_ context: ErrorContext) {
        let message = context.summary
        Core.logError(message, category: .error)
    }
}

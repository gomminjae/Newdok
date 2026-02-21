//
//  CheckResult.swift
//  Domain
//
//  Created by 권민재 on 4/7/25.
//

public enum CheckResult<T> {
    case exists(T)
    case notFound // 400
}

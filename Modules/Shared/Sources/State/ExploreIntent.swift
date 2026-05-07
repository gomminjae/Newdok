//
//  ExploreIntent 2.swift
//  Shared
//
//  Created by 권민재 on 7/13/25.
//

import Foundation
import Observation

@Observable
@MainActor
public final class ExploreIntent {
    public var day: Int?
    public var selectedTab: Int?
    public var trigger = UUID()
    public init() {}
} 

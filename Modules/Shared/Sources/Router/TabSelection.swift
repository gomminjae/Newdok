//
//  TabSelection.swift
//  Shared
//
//  Created by 권민재 on 5/21/25.
//
import SwiftUI
import Observation

@Observable
@MainActor
public final class TabSelection {
    public var selectedTab: NewDokTab = .home

    public private(set) var exploreDay: Int?
    public private(set) var exploreTab: Int = 0
    public private(set) var hasPendingExplore: Bool = false
    public private(set) var exploreTrigger = UUID()

    public init() {}

    public func moveToExplore(day: Int? = nil, tab: Int) {
        exploreDay = day
        exploreTab = tab
        hasPendingExplore = true
        exploreTrigger = UUID()
        selectedTab = .explore
    }

    public func consumeExploreParams() -> (day: Int?, tab: Int) {
        let result = (day: exploreDay, tab: exploreTab)
        exploreDay = nil
        hasPendingExplore = false
        return result
    }
}

public enum NewDokTab: Int, CaseIterable {
    case explore
    case subscribe
    case home
    case bookmark
    case profile
}

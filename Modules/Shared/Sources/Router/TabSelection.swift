//
//  TabSelection.swift
//  Shared
//
//  Created by 권민재 on 5/21/25.
//
import SwiftUI
import Combine

@MainActor
public final class TabSelection: ObservableObject {
    @Published public var selectedTab: NewDokTab = .home

    public init() {}
}

public enum NewDokTab: Int, CaseIterable {
    case explore
    case subscribe
    case home
    case bookmark
    case profile
}
